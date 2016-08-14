package com.gibbon.peeq.handlers;

import java.io.IOException;

import org.apache.commons.lang.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.gibbon.peeq.db.model.Journal;
import com.gibbon.peeq.db.model.Journal.JournalType;
import com.gibbon.peeq.db.model.QaTransaction;
import com.gibbon.peeq.db.model.QaTransaction.TransType;
import com.gibbon.peeq.db.model.Quanda.QnaStatus;
import com.gibbon.peeq.db.model.Snoop;
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.db.util.JournalUtil;
import com.gibbon.peeq.db.util.PcAccountUtil;
import com.gibbon.peeq.db.util.ProfileUtil;
import com.gibbon.peeq.util.ResourceURIParser;
import com.gibbon.peeq.util.StripeUtils;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class QaTransactionWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {

  protected static final Logger LOG = LoggerFactory
      .getLogger(QaTransactionWebHandler.class);
  private final static double SNOOP_RATE = 1.5;

  public QaTransactionWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onGet();
  }

  private FullHttpResponse onGet() {
    /* get id */
    final String id = getUriParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Transaction txn = null;
    Session session = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      final QaTransaction retInstance = (QaTransaction) session
          .get(QaTransaction.class, Long.parseLong(id));
      txn.commit();

      /* buffer result */
      appendNewInstance(id, retInstance);
      return newResponse(HttpResponseStatus.OK);
    } catch (HibernateException e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  private void appendNewInstance(final String id, final QaTransaction instance)
      throws JsonProcessingException {
    if (instance != null) {
      appendByteArray(instance.toJsonByteArray());
    } else {
      appendln(String
          .format("Nonexistent resource with URI: /qatransactions/%s", id));
    }
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }


  /*
   * <ul> <li>In the case of ASKING transaction, inserting quanda and
   * qaTransaction, and charging asker must be atomic. </li> <li>In the case of
   * SNOOPING, inserting snoop and qaTransaction, and charging snooper must be
   * atomic.</li> </ul>
   */
  private FullHttpResponse onCreate() {
    final QaTransaction fromJson;
    /* new instance from request */
    try {
      fromJson = newInstanceFromRequest();
      if (fromJson == null) {
        appendln("No QaTransaction or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* verify uid */
    final String uid = fromJson.getUid();
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* verify transaction type */
    if (!TransType.ASKED.toString().equals(fromJson.getType())
        && !TransType.SNOOPED.toString().equals(fromJson.getType())) {
      appendln(String.format("Unsupported QaTransaction type ('%s')",
          fromJson.getType()));
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (TransType.ASKED.toString().equals(fromJson.getType())) {
      /* charge asker */
      return chargeAsker(fromJson);
    } else if (TransType.SNOOPED.toString().equals(fromJson.getType())) {
      /* charge snooper */
      return chargeSnooper(fromJson);
    } else {
      return null;
    }
  }

  /*
   * each 1/3 of charge of snooping goes to platform, asker and responder,
   * respectively.
   */
  private FullHttpResponse chargeSnooper(final QaTransaction qaTransaction) {
    Session session = null;
    Transaction txn = null;
    FullHttpResponse resp = null;

    final String transUserId = qaTransaction.getUid();

    /* verify quanda */
    final Quanda quanda = qaTransaction.getquanda();
    resp = verifyQuandaForSnooping(quanda);
    if (resp != null) {
      return resp;
    }

    /* QaTransaction user shouldn't be same as quanda asker or responder */
    resp = verifyTransactionUserShoundNotBeSameAsAskerOrResponder(transUserId,
        quanda);
    if (resp != null) {
      return resp;
    }

    /* get answer rate */
    double answerRate = 0;
    try {
      answerRate = ProfileUtil.getRate(quanda.getResponder());
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* get snooper balance */
    double balance = 0;
    try {
      balance = JournalUtil.getBalanceIgnoreNull(transUserId);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    if (answerRate <= 0) { /* free to snoop */
      /* insert snoop and qaTransaction */

      session = getSession();
      txn = session.beginTransaction();

      /* insert snoop and qaTransaction */
      insertSnoopAndQaTransaction(session, quanda, qaTransaction, 0);

      txn.commit();
      appendln(Long.toString(qaTransaction.getId()));
      return newResponse(HttpResponseStatus.CREATED);
    } else { /* pay to snoop */
      /* insert snoop, qaTransaction and journals */

      try {
        session = getSession();
        txn = session.beginTransaction();

        /* insert snoop and qaTransaction */
        insertSnoopAndQaTransaction(session, quanda, qaTransaction, SNOOP_RATE);

        /* insert journals and charge */
        if (balance >= SNOOP_RATE) {
          chargeSnooperFromBalance(session, qaTransaction, quanda, SNOOP_RATE);
        } else {
          chargeSnooperFromCard(session, qaTransaction, quanda, SNOOP_RATE);
        }
        txn.commit();
        appendln(toIdJson("id", qaTransaction.getId()));
        return newResponse(HttpResponseStatus.CREATED);
      } catch (Exception e) {
        txn.rollback();
        return newServerErrorResponse(e, LOG);
      }
    }
  }

  private FullHttpResponse verifyQuandaForAsking(final String asker,
      final Quanda quanda) {
    if (quanda == null) {
      appendln("No quanda or incorrect format specified.");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (StringUtils.isBlank(quanda.getQuestion())) {
      appendln("No question specified in quanda");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (StringUtils.isBlank(quanda.getResponder())) {
      appendln("No responder specified in quanda");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (quanda.getResponder().equals(asker)) {
      appendln(String.format(
          "Quanda asker ('%s') can't be the same as responder ('%s')",
          quanda.getAsker(), quanda.getResponder()));
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    return null;
  }

  private FullHttpResponse verifyQuandaForSnooping(final Quanda quanda) {
    if (quanda == null) {
      appendln("No quanda or incorrect format specified.");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (quanda.getId() <= 0) {
      appendln("Incorrect quanda id specified");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (StringUtils.isBlank(quanda.getAsker())) {
      appendln("No asker specified in quanda");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (StringUtils.isBlank(quanda.getResponder())) {
      appendln("No responder specified in quanda");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (quanda.getAsker().equals(quanda.getResponder())) {
      appendln(String.format(
          "Quanda asker ('%s') can't be the same as responder ('%s')",
          quanda.getAsker(), quanda.getResponder()));
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    return null;
  }

  private FullHttpResponse verifyTransactionUserShoundNotBeSameAsAskerOrResponder(
      final String transUserId, final Quanda quanda) {
    if (transUserId.equals(quanda.getAsker())
        || transUserId.equals(quanda.getResponder())) {
      appendln(String.format(
          "QaTransaction user ('%s') shouldn't be same as quanda asker ('%s') or responder ('%s')",
          transUserId, quanda.getAsker(), quanda.getResponder()));
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    return null;
  }

  /*
   * 1/10 of charge of asking goes to platform, 9/10 goes to responder.
   */
  private FullHttpResponse chargeAsker(final QaTransaction qaTransaction) {
    Session session = null;
    Transaction txn = null;
    FullHttpResponse resp = null;

    final String transUserId = qaTransaction.getUid();

    /* verify quanda */
    final Quanda quanda = qaTransaction.getquanda();
    resp = verifyQuandaForAsking(qaTransaction.getUid(), quanda);
    if (resp != null) {
      return resp;
    }
    /* QaTransaction user must be same as quanda asker */
    quanda.setAsker(qaTransaction.getUid());
    quanda.setStatus(QnaStatus.PENDING.toString());

    /* get answer rate */
    double answerRate = 0;
    try {
      answerRate = ProfileUtil.getRate(quanda.getResponder());
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* get asker balance */
    double balance = 0;
    try {
      balance = JournalUtil.getBalanceIgnoreNull(transUserId);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    if (answerRate <= 0) { /* free to ask */
      /* insert quanda and qaTransaction */

      try {
        session = getSession();
        txn = session.beginTransaction();

        /* insert quanda and qaTransaction */
        insertQuandaAndQaTransaction(session, quanda, qaTransaction, 0);

        txn.commit();
        appendln(Long.toString(qaTransaction.getId()));
        return newResponse(HttpResponseStatus.CREATED);
      } catch (Exception e) {
        txn.rollback();
        return newServerErrorResponse(e, LOG);
      }
    } else { /* pay to ask */
      /* insert quanda, qaTransaction and journals */

      try {
        session = getSession();
        txn = session.beginTransaction();

        /* insert quanda and qaTransaction */
        insertQuandaAndQaTransaction(session, quanda, qaTransaction,
            answerRate);

        /* insert journals and charge */
        if (balance >= answerRate) {
          chargeAskerFromBalance(session, qaTransaction, quanda, answerRate);
        } else {
          chargeAskerFromCard(session, qaTransaction, quanda, answerRate);
        }
        txn.commit();
        appendln(toIdJson("id", qaTransaction.getId()));
        return newResponse(HttpResponseStatus.CREATED);
      } catch (Exception e) {
        txn.rollback();
        return newServerErrorResponse(e, LOG);
      }
    }
  }

  private void insertSnoopAndQaTransaction(final Session session,
      final Quanda quanda, final QaTransaction qaTransaction,
      final double snoopRate) {
    /* insert snoop */
    final Snoop snoop = new Snoop();
    snoop.setUid(qaTransaction.getUid()).setQuandaId(quanda.getId());
    session.save(snoop);

    /* insert qaTransaction */
    qaTransaction.setType(TransType.SNOOPED.toString());
    qaTransaction.setQuandaId(quanda.getId());
    qaTransaction.setAmount(snoopRate);
    session.save(qaTransaction);
  }

  private void insertQuandaAndQaTransaction(final Session session,
      final Quanda quanda, final QaTransaction qaTransaction,
      final double answerRate) {
    /* insert quanda */
    session.save(quanda);

    /* insert qaTransaction */
    qaTransaction.setType(TransType.ASKED.toString());
    qaTransaction.setQuandaId(quanda.getId());
    qaTransaction.setAmount(answerRate);
    session.save(qaTransaction);
  }

  private void chargeSnooperFromBalance(final Session session,
      final QaTransaction qaTransaction, final Quanda quanda,
      final double snoopRate) {

    /* insert journal for snooper, asker and responder */
    insertJournalsOfSnoopingQuanda(session, qaTransaction, quanda, snoopRate,
        JournalType.BALANCE);
  }

  private void chargeAskerFromBalance(final Session session,
      final QaTransaction qaTransaction, final Quanda quanda,
      final double answerRate) {

    /* insert journal for asker and responder */
    insertJournalsOfAskingQuanda(session, qaTransaction, quanda, answerRate,
        JournalType.BALANCE);
  }

  private void chargeSnooperFromCard(final Session session,
      final QaTransaction qaTransaction, final Quanda quanda,
      final double snoopRate) throws Exception {

    /* insert journal for snooper, asker and responder */
    insertJournalsOfSnoopingQuanda(session, qaTransaction, quanda, snoopRate,
        JournalType.CARD);

    /* charge snooper from card */
    final String cusId = PcAccountUtil.getCustomerId(session,
        qaTransaction.getUid());
    StripeUtils.chargeCustomer(cusId, snoopRate);
  }

  private void chargeAskerFromCard(final Session session,
      final QaTransaction qaTransaction, final Quanda quanda,
      final double answerRate) throws Exception {

    /* insert journal for asker and responder */
    insertJournalsOfAskingQuanda(session, qaTransaction, quanda, answerRate,
        JournalType.CARD);

    /* charge asker from card */
    final String cusId = PcAccountUtil.getCustomerId(session,
        qaTransaction.getUid());
    StripeUtils.chargeCustomer(cusId, answerRate);
  }

  private void insertJournalsOfSnoopingQuanda(final Session session,
      final QaTransaction qaTransaction, final Quanda quanda,
      final double snoopRate, final JournalType snooperJournalType) {
    Journal journal = null;

    /* insert journal for snooper */
    journal = newJournal(qaTransaction.getId(), qaTransaction.getUid(),
        -1 * snoopRate, snooperJournalType);
    session.save(journal);

    /* insert journal for asker */
    journal = newJournal(qaTransaction.getId(), quanda.getAsker(),
        snoopRate / 3, JournalType.BALANCE);
    session.save(journal);

    /* insert journal for responder */
    journal = newJournal(qaTransaction.getId(), quanda.getResponder(),
        snoopRate / 3, JournalType.BALANCE);
    session.save(journal);
  }

  private void insertJournalsOfAskingQuanda(final Session session,
      final QaTransaction qaTransaction, final Quanda quanda,
      final double answerRate, final JournalType askerJournalType) {
    Journal journal = null;

    /* insert journal for asker */
    journal = newJournal(qaTransaction.getId(), quanda.getAsker(),
        -1 * answerRate, askerJournalType);
    session.save(journal);

    /* insert journal for responder */
    journal = newJournal(qaTransaction.getId(), quanda.getResponder(),
        answerRate * 0.9, JournalType.BALANCE);
    session.save(journal);
  }

  private Journal newJournal(final long transactionId, final String uid,
      final double amount, final JournalType journalType) {
    final Journal journal = new Journal();
    journal.setTransactionId(transactionId)
           .setUid(uid)
           .setAmount(amount)
           .setType(journalType.toString());
    return journal;
  }

  private QaTransaction newInstanceFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return QaTransaction.newInstance(json);
    }
    return null;
  }
}
