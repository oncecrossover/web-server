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
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.db.util.JournalUtil;
import com.gibbon.peeq.db.util.PcAccountUtil;
import com.gibbon.peeq.db.util.ProfileUtil;
import com.gibbon.peeq.db.util.QuandaUtil;
import com.gibbon.peeq.exceptions.SnoopException;
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

    /* verify amount */
    if (fromJson.getAmount() == null || fromJson.getAmount() < 0) {
      appendln(String.format("Incorrect amount ('%s') format",
          fromJson.getAmount()));
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* verify transaction type */
    if (!TransType.ASKED.toString().equals(fromJson.getType())
        && !TransType.SNOOPED.toString().equals(fromJson.getType())) {
      appendln(String.format("Unsupported QaTransaction type ('%s')",
          fromJson.getType()));
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* verify uid */
    final String uid = fromJson.getUid();
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* get balance */
    double balance = 0;
    try {
      balance = JournalUtil.getBalanceIgnoreNull(uid);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    Session session;
    Transaction txn = null;
    /* TODO: this amount could be inconsistent with ask/snoop fee */
    if (balance > fromJson.getAmount()) {
      /* charge from balance */

      try {
        /* insert transactions and journals */
        session = getSession();
        txn = session.beginTransaction();
        InsertTransactionAndJournals(session, fromJson, balance,
            JournalType.BALANCE);

        /* commit inserting transaction and journals */
        txn.commit();
        appendln(
            String.format("New resource created with URI: /qatransactions/%d",
                fromJson.getId()));
        return newResponse(HttpResponseStatus.CREATED);
      } catch (HibernateException e) {
        txn.rollback();
        return newServerErrorResponse(e, LOG);
      } catch (Exception e) {
        return newServerErrorResponse(e, LOG);
      }
    } else {
      /* charge from card */

      try {
        /* insert transactions and journals */
        session = getSession();
        txn = session.beginTransaction();
        InsertTransactionAndJournals(session, fromJson, balance,
            JournalType.CARD);

        /* charge user (i.e. asker or snooper) */
        final String cusId = PcAccountUtil.getCustomerId(session,
            fromJson.getUid());
        /* TODO: this amount could be inconsistent with ask/snoop fee */
        StripeUtils.chargeCustomer(cusId, fromJson.getAmount());

        /* commit inserting transaction and journals */
        txn.commit();
        appendln(Long.toString(fromJson.getId()));
        return newResponse(HttpResponseStatus.CREATED);
      } catch (HibernateException e) {
        txn.rollback();
        return newServerErrorResponse(e, LOG);
      } catch (Exception e) {
        return newServerErrorResponse(e, LOG);
      }
    }
  }

  private void InsertTransactionAndJournals(final Session session,
      final QaTransaction qaTransaction, final double balance,
      final JournalType chargeJournalType) throws Exception {

    final String transUserId = qaTransaction.getUid();

    /* insert qaTransaction */
    session.save(qaTransaction);

    /* query quanda */
    final Quanda quanda = QuandaUtil.getQuanda(session,
        qaTransaction.getQuandaId());

    Journal journal = null;
    /* asked question */
    if (TransType.ASKED.toString().equals(qaTransaction.getType())) {
      /* quanda's asker not match with transaction's asker */
      if (!quanda.getAsker().equals(transUserId)) {
        throw new SnoopException(String.format(
            "Quanda's asker ('%s') not match with transaction's user ('%s')",
            quanda.getAsker(), transUserId));
      }

      /* get rate for responder */
      final double answerRate = ProfileUtil.getRate(session,
          quanda.getResponder());

      /* free to ask */
      if (answerRate == 0) {
        return;
      }

      /* verify balance */
      verifyBalance(transUserId, balance, answerRate, chargeJournalType);

      /* insert journal for asker */
      journal = newJournal(qaTransaction.getId(), quanda.getAsker(),
          -1 * answerRate, chargeJournalType);
      session.save(journal);

      /* insert journal for responder */
      journal = newJournal(qaTransaction.getId(), quanda.getResponder(),
          answerRate, JournalType.BALANCE);
      session.save(journal);
    } else if (TransType.SNOOPED.toString().equals(qaTransaction.getType())) {
      /* snooped question */

      /* set snoop reate */
      final double snoopRate = 1.5;

      /* verify balance */
      verifyBalance(transUserId, balance, snoopRate, chargeJournalType);

      /* insert journal for snooper */
      journal = newJournal(qaTransaction.getId(), transUserId, -1 * snoopRate,
          chargeJournalType);
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
  }

  private void verifyBalance(final String chargedUser, final double balance,
      final double chargeAmount, final JournalType chargeJournalType)
      throws SnoopException {
    /* verify balance */
    if (chargeJournalType == JournalType.BALANCE && chargeAmount > balance) {
      throw new SnoopException(
          String.format("User ('%s') has balance (%d) not enough to pay %d",
              chargedUser, balance, chargeAmount));
    }
  }

  private Journal newJournal(final long transactionId, final String uid,
      final double amount, final JournalType journalType) {
    final Journal journal = new Journal();
    journal.setTransactionId(transactionId).setUid(uid).setAmount(amount)
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
