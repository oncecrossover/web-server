package com.snoop.server.web.handlers;

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
import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.CoinEntry;
import com.snoop.server.db.model.Journal;
import com.snoop.server.db.model.Profile;
import com.snoop.server.db.model.QaTransaction;
import com.snoop.server.db.model.Quanda;
import com.snoop.server.db.model.Snoop;
import com.snoop.server.db.model.Journal.JournalType;
import com.snoop.server.db.model.QaTransaction.TransType;
import com.snoop.server.db.util.CoinDBUtil;
import com.snoop.server.db.util.ProfileDBUtil;
import com.snoop.server.db.util.QuandaDBUtil;
import com.snoop.server.db.util.UserDBUtil;
import com.snoop.server.util.EmailUtil;
import com.snoop.server.util.NotificationUtil;
import com.snoop.server.util.ResourcePathParser;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class QaTransactionWebHandler extends AbastractWebHandler
    implements WebHandler {

  protected static final Logger LOG = LoggerFactory
      .getLogger(QaTransactionWebHandler.class);

  private final static int CENTS_PER_COIN = 4;
  private final static int COINS_PER_SNOOP = 8;
  private final static double SNOOP_RATE = (CENTS_PER_COIN * COINS_PER_SNOOP
      * 1.0) / 100;
  private final static double ASKER_REWARDS = 0.1;
  private final static double RESPONDER_REWARDS = 0.1;

  public QaTransactionWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onGet();
  }

  private FullHttpResponse onGet() {
    /* get id */
    final String id = getPathParser().getPathStream().nextToken();

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
      return newResponseForInstance(id, retInstance);
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse newResponseForInstance(final String id,
      final QaTransaction instance) throws JsonProcessingException {
    if (instance != null) {
      appendByteArray(instance.toJsonByteArray());
      return newResponse(HttpResponseStatus.OK);
    } else {
      appendln(String
          .format("Nonexistent resource with URI: /qatransactions/%s", id));
      return newResponse(HttpResponseStatus.NOT_FOUND);
    }
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }


  /**
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
    final Long uid = fromJson.getUid();
    if (uid == null) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* verify transaction type */
    if (!TransType.ASKED.value().equals(fromJson.getType())
        && !TransType.SNOOPED.value().equals(fromJson.getType())) {
      appendln(String.format("Unsupported QaTransaction type ('%s')",
          fromJson.getType()));
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (TransType.ASKED.value().equals(fromJson.getType())) {
      /* charge asker */
      return chargeAsker(fromJson);
    } else if (TransType.SNOOPED.value().equals(fromJson.getType())) {
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

    final Long transUid = qaTransaction.getUid();

    /* get client copy */
    final Quanda quandaFromClient = qaTransaction.getquanda();
    resp = verifyQuandaFromClientForSnooping(quandaFromClient);
    if (resp != null) {
      return resp;
    }

    /* get DB copy */
    Quanda quandaFromDB = null;
    try {
      quandaFromDB = QuandaDBUtil.getQuanda(getSession(),
          quandaFromClient.getId(), true);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
    resp = verifyQuandaFromDBForSnooping(quandaFromDB);
    if (resp != null) {
      return resp;
    }

    /* QaTransaction user shouldn't be same as quanda asker or responder */
    resp = verifyTransactionForSnooping(transUid, quandaFromDB);
    if (resp != null) {
      return resp;
    }

    if (quandaFromDB.getRate() <= 0) { /* free to snoop */
      /* insert snoop */

      session = getSession();
      txn = session.beginTransaction();

      /* insert snoop */
      insertSnoop(session, quandaFromDB, qaTransaction);

      txn.commit();
      appendln(toIdJson("id", qaTransaction.getId()));
      return newResponse(HttpResponseStatus.CREATED);
    } else { /* pay to snoop */
      /* insert snoop, qaTransaction, journals and CoinEntry */

      try {
        session = getSession();
        txn = session.beginTransaction();

        /* insert snoop and qaTransaction */
        insertSnoopAndQaTransaction(session, quandaFromDB, qaTransaction);

        /* get asker coins */
        long coins = 0;
        try {
          coins = CoinDBUtil.getCoinsIgnoreNull(transUid, session, false);
        } catch (Exception e) {
          if (txn != null && txn.isActive()) {
            txn.rollback();
          }
          return newServerErrorResponse(e, LOG);
        }

        /* insert journals and charge */
        if (toDollarsFromCoins(coins) >= SNOOP_RATE) {
          chargeSnooperFromCoins(session, qaTransaction, quandaFromDB);
          txn.commit();
        } else {
          txn.rollback();
          appendln("Not enough coins to pay to snoop answers.");
          return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
        }

        /* send payment confirmation to snooper */
        sendPaymentConfirmation(qaTransaction, SNOOP_RATE);

        appendln(toIdJson("id", qaTransaction.getId()));
        return newResponse(HttpResponseStatus.CREATED);
      } catch (Exception e) {
        if (txn != null && txn.isActive()) {
          txn.rollback();
        }
        return newServerErrorResponse(e, LOG);
      }
    }
  }

  private static FullHttpResponse verifyQuandaForAsking(
      final Quanda quanda,
      final ByteArrayDataOutput respBuf) {
    return QuandaWebHandler.verifyQuanda(quanda, respBuf);
  }

  private FullHttpResponse verifyQuandaFromClientForSnooping(
      final Quanda quanda) {
    if (quanda == null) {
      appendln("No quanda or incorrect format specified.");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (quanda.getId() == null || quanda.getId() <= 0) {
      appendln("Incorrect or no quanda id specified");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    return null;
  }

  private FullHttpResponse verifyQuandaFromDBForSnooping(final Quanda quanda) {

    FullHttpResponse resp = verifyQuandaFromClientForSnooping(quanda);
    if (resp != null) {
      return resp;
    }

    if (quanda.getAsker() == null) {
      appendln("No asker specified in quanda");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (quanda.getResponder() == null) {
      appendln("No responder specified in quanda");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    if (quanda.getAsker().equals(quanda.getResponder())) {
      appendln(String.format(
          "Quanda asker ('%d') can't be the same as responder ('%d')",
          quanda.getAsker(), quanda.getResponder()));
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    return null;
  }

  private FullHttpResponse verifyTransactionForSnooping(
      final Long transUid, final Quanda quanda) {
    if (transUid.equals(quanda.getAsker())
        || transUid.equals(quanda.getResponder())) {
      appendln(String.format(
          "QaTransaction user ('%d') shouldn't be same as quanda asker ('%d') or responder ('%d')",
          transUid, quanda.getAsker(), quanda.getResponder()));
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    return null;
  }

  /*
   * 0/10 of charge of asking goes to platform, 7/10 goes to responder.
   */
  private FullHttpResponse chargeAsker(final QaTransaction qaTransaction) {
    Session session = null;
    Transaction txn = null;
    FullHttpResponse resp = null;
    final Long transUid = qaTransaction.getUid();

    /* get quanda */
    final Quanda quanda = qaTransaction.getquanda();
    if (quanda == null) {
      appendln("No quanda or incorrect format specified.");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* QaTransaction user must be same as quanda asker */
    quanda.setAsker(transUid);

    /* get answer rate */
    int answerRate = 0;
    try {
      answerRate = ProfileDBUtil.getRate(getSession(), quanda.getResponder(),
          true);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
    quanda.setRate(answerRate);

    /* verify quanda */
    resp = verifyQuandaForAsking(quanda, getRespBuf());
    if (resp != null) {
      return resp;
    }

    if (answerRate <= 0) { /* free to ask */
      /* insert quanda */

      try {
        session = getSession();
        txn = session.beginTransaction();

        /* insert quanda */
        insertQuanda(session, quanda);

        txn.commit();

        /* send notification */
        sendNotificationToResponder(qaTransaction);

        appendln(toIdJson("id", qaTransaction.getId()));
        return newResponse(HttpResponseStatus.CREATED);
      } catch (Exception e) {
        if (txn != null && txn.isActive()) {
          txn.rollback();
        }
        return newServerErrorResponse(e, LOG);
      }
    } else { /* pay to ask */
      /* insert quanda, qaTransaction, journals and CoinEntry */

      try {
        session = getSession();
        txn = session.beginTransaction();

        /* insert quanda and qaTransaction */
        insertQuandaAndQaTransaction(session, quanda, qaTransaction,
          answerRate);

        /* get asker coins */
        long coins = 0;
        try {
          coins = CoinDBUtil.getCoinsIgnoreNull(transUid, session, false);
        } catch (Exception e) {
          return newServerErrorResponse(e, LOG);
        }

        /* insert journals and CoinEntry */
        if (toDollarsFromCoins(coins) >= answerRate) {
          chargeAskerFromCoins(session, qaTransaction, quanda, answerRate);
          txn.commit();
        } else {
          txn.rollback();
          appendln("Not enough coins to pay to ask questions.");
          return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
        }

        /* send payment confirmation to asker */
        sendPaymentConfirmation(qaTransaction, answerRate);

        /* send notification */
        sendNotificationToResponder(qaTransaction);

        appendln(toIdJson("id", qaTransaction.getId()));
        return newResponse(HttpResponseStatus.CREATED);
      } catch (Exception e) {
        if (txn != null && txn.isActive()) {
          txn.rollback();
        }
        return newServerErrorResponse(e, LOG);
      }
    }
  }

  private void sendPaymentConfirmation(
      final QaTransaction qaTransaction,
      final double amount) {

    final String email = UserDBUtil.getEmailByUid(getSession(),
        qaTransaction.getUid(), true);
    EmailUtil.sendPaymentConfirmation(
      email,
      qaTransaction.getquanda().getQuestion(),
      amount);
  }

  private void sendNotificationToResponder(final QaTransaction qaTransaction) {
    final Profile responderProfile = ProfileDBUtil.getProfileForNotification(
        getSession(), qaTransaction.getquanda().getResponder(), true);
    final Profile askerProfile = ProfileDBUtil.getProfileForNotification(
        getSession(), qaTransaction.getquanda().getAsker(), true);

    if (responderProfile != null
        && !StringUtils.isEmpty(responderProfile.getDeviceToken())
        && askerProfile != null) {
      final String title = askerProfile.getFullName()
          + " just asked you a question:";
      final String message = qaTransaction.getquanda().getQuestion();
      NotificationUtil.sendNotification(title, message,
          responderProfile.getDeviceToken());
    }
  }

  /**
   * Convert coins to dollars.
   */
  private double toDollarsFromCoins(final long coins) {
    return coins * CENTS_PER_COIN * 1.0 / 100;
  }

  /**
   * Convert dollars to coins.
   */
  private int toCoinsFromDollars(final double dollars) {
    return ((int) Math.ceil(dollars * 100 / CENTS_PER_COIN));
  }

  private void insertSnoop(final Session session, final Quanda quanda,
      final QaTransaction qaTransaction) {
    /* insert snoop */
    final Snoop snoop = new Snoop();
    snoop.setUid(qaTransaction.getUid()).setQuandaId(quanda.getId());
    session.save(snoop);
  }

  private void insertSnoopAndQaTransaction(final Session session,
      final Quanda quanda, final QaTransaction qaTransaction) {
    /* insert snoop */
    final Snoop snoop = new Snoop();
    snoop.setUid(qaTransaction.getUid()).setQuandaId(quanda.getId());
    session.save(snoop);

    /* insert qaTransaction */
    qaTransaction.setType(TransType.SNOOPED.value());
    qaTransaction.setQuandaId(quanda.getId());
    qaTransaction.setAmount(Math.abs(SNOOP_RATE));
    session.save(qaTransaction);
  }

  private void insertQuanda(final Session session, final Quanda quanda) {
    /* insert quanda */
    session.save(quanda);
  }

  private void insertQuandaAndQaTransaction(final Session session,
      final Quanda quanda, final QaTransaction qaTransaction,
      final int answerRate) {
    /* insert quanda */
    session.save(quanda);

    /* insert qaTransaction */
    qaTransaction.setType(TransType.ASKED.value());
    qaTransaction.setQuandaId(quanda.getId());
    qaTransaction.setAmount(Math.abs(answerRate));
    session.save(qaTransaction);
  }

  private void chargeSnooperFromCoins(final Session session,
      final QaTransaction qaTransaction, final Quanda quanda) {

    /* insert CoinEntry for snoper */
    final CoinEntry coinEntry = insertCoinEntryOfSnoopingQuanda(session,
        qaTransaction);

    /* insert journal for snooper, asker and responder */
    insertJournalsOfSnoopingQuanda(session, qaTransaction, quanda, coinEntry);
  }

  /**
   * charge asker from coins. The charge will be refunded if responder doesn't
   * answer the questions within 48 hours.
   */
  private void chargeAskerFromCoins(
      final Session session,
      final QaTransaction qaTransaction,
      final Quanda quanda,
      final int answerRate) {

    /* insert CoinEntry for asker */
    final CoinEntry coinEntry = insertCoinEntryOfAskingQuanda(session,
        qaTransaction);

    /* insert journal for asker */
    insertJournalsOfAskingQuanda(
        session,
        qaTransaction,
        quanda,
        coinEntry,
        answerRate);
  }

  int minusCoinsForSnooping() {
    return -1 * COINS_PER_SNOOP;
  }

  private CoinEntry insertCoinEntryOfSnoopingQuanda(
      final Session session,
      final QaTransaction qaTransaction) {
    final CoinEntry coinEntry = new CoinEntry();
    coinEntry.setUid(qaTransaction.getUid())
             .setAmount(minusCoinsForSnooping());
    session.save(coinEntry);
    return coinEntry;
  }

  int negativeCoinsForAsking(final QaTransaction qaTransaction) {
    return -1 * Math.abs(toCoinsFromDollars(qaTransaction.getAmount()));
  }

  private CoinEntry insertCoinEntryOfAskingQuanda(
      final Session session,
      final QaTransaction qaTransaction) {
    final CoinEntry coinEntry = new CoinEntry();
    coinEntry.setUid(qaTransaction.getUid())
             .setAmount(negativeCoinsForAsking(qaTransaction));
    session.save(coinEntry);
    return coinEntry;
  }

  int negativeAskerCost(final int answerRate) {
    return -1 * Math.abs(answerRate);
  }

  /**
   * There's potential EXPIRE for asking, so charge should be created as
   * PENDING. A follow-on payment journal will be created as CLEARED when the
   * question is answered.
   */
  private void insertJournalsOfAskingQuanda(
      final Session session,
      final QaTransaction qaTransaction,
      final Quanda quanda,
      final CoinEntry coinEntry,
      final int answerRate) {

    /* insert journal for asker */
    final Journal journal = new Journal();
    journal.setTransactionId(qaTransaction.getId())
           .setUid(quanda.getAsker())
           .setAmount(negativeAskerCost(answerRate))
           .setType(JournalType.COIN.value())
           .setCoinEntryId(coinEntry.getId());

    session.save(journal);
  }

  private double minusSnoopRate() {
    return -1 * Math.abs(SNOOP_RATE);
  }

  /**
   * There's no EXPIRE for snoop, so charge and payment should be
   * created as CLEARED.
   */
  private void insertJournalsOfSnoopingQuanda(
      final Session session,
      final QaTransaction qaTransaction,
      final Quanda quanda,
      final CoinEntry coinEntry) {

    /* insert journal for snooper */
    final Journal snooperJournal = new Journal();
    snooperJournal.setTransactionId(qaTransaction.getId())
        .setUid(qaTransaction.getUid())
        .setAmount(minusSnoopRate())
        .setType(JournalType.COIN.value())
        .setStatus(Journal.Status.CLEARED.value())
        .setCoinEntryId(coinEntry.getId());
    session.save(snooperJournal);

    /* insert journal for asker */
    final Journal askerJournal = new Journal();
    askerJournal.setTransactionId(qaTransaction.getId())
        .setUid(quanda.getAsker())
        .setAmount(Math.abs(ASKER_REWARDS))
        .setType(JournalType.BALANCE.value())
        .setStatus(Journal.Status.CLEARED.value())
        .setOriginId(snooperJournal.getId());
    session.save(askerJournal);

    /* insert journal for responder */
    final Journal responderJournal = new Journal();
    responderJournal.setTransactionId(qaTransaction.getId())
        .setUid(quanda.getResponder())
        .setAmount(Math.abs(RESPONDER_REWARDS))
        .setType(JournalType.BALANCE.value())
        .setStatus(Journal.Status.CLEARED.value())
        .setOriginId(snooperJournal.getId());
    session.save(responderJournal);
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
