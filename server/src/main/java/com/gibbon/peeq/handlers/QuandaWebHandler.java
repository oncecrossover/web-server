package com.gibbon.peeq.handlers;

import java.io.IOException;
import java.util.Date;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.gibbon.peeq.db.model.Journal;
import com.gibbon.peeq.db.model.QaTransaction;
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.db.util.HibernateTestUtil;
import com.gibbon.peeq.db.util.JournalUtil;
import com.gibbon.peeq.db.util.QaTransactionUtil;
import com.gibbon.peeq.exceptions.SnoopException;
import com.gibbon.peeq.util.ObjectStoreClient;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class QuandaWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(QuandaWebHandler.class);

  public QuandaWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    PeeqWebHandler pwh = new QuandaFilterWebHandler(getUriParser(),
        getRespBuf(), getHandlerContext(), getRequest());

    if (pwh.willFilter()) {
      return pwh.handle();
    } else {
      return onGet();
    }
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdate();
  }

  private FullHttpResponse onGet() {
    /* get id */
    final String id = getUriParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      final Quanda retInstance = (Quanda) session.get(Quanda.class,
          Long.parseLong(id));
      txn.commit();

      /* load from object store */
      setAnswerAudio(retInstance);

      /* buffer result */
      return newResponseForInstance(id, retInstance);
    } catch (HibernateException e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  private void setAnswerAudio(final Quanda quanda) {
    if (quanda == null) {
      return;
    }

    final byte[] readContent = readAnswerAudio(quanda);
    if (readContent != null) {
      quanda.setAnswerAudio(readContent);
    }
  }

  private byte[] readAnswerAudio(final Quanda quanda) {
    ObjectStoreClient osc = new ObjectStoreClient();
    try {
      return osc.readAnswerAudio(quanda.getAnswerUrl());
    } catch (Exception e) {
      LOG.warn(super.stackTraceToString(e));
    }
    return null;
  }

  private FullHttpResponse newResponseForInstance(final String id,
      final Quanda instance) throws JsonProcessingException {
    if (instance != null) {
      appendByteArray(instance.toJsonByteArray());
      return newResponse(HttpResponseStatus.OK);
    } else {
      appendln(String.format("Nonexistent resource with URI: /quandas/%s", id));
      return newResponse(HttpResponseStatus.NOT_FOUND);
    }
  }

  /*
   * Quanda.status and Quanda.answerUrl (as a result of Quanda.answerAudio) are
   * the only DB columns that can be updated by client.
   */
  private void checkColumnsToBeUpdated(final Quanda fromJson)
      throws SnoopException {
    /* check fields not allowed to be updated */
    if (fromJson.getId() != null ||
        fromJson.getAsker() != null ||
        fromJson.getQuestion() != null ||
        fromJson.getResponder() != null ||
        fromJson.getRate() != null ||
        fromJson.getAnswerUrl() != null ||
        fromJson.getCreatedTime() != null ||
        fromJson.getUpdatedTime() != null ||
        fromJson.getSnoops() != null) {
      throw new SnoopException(
          "The fields except answerAudio and status can't be updated");
    }

    /* check ANSWERED only */
    if (fromJson.getStatus() != null
        && !fromJson.getStatus().equals(Quanda.QnaStatus.ANSWERED.toString())) {
      throw new SnoopException(
          "The status can be changed to ANSWERED only in this API");
    }
  }


  private FullHttpResponse onUpdate() {
    /* get id */
    final String id = getUriParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* get instance from json */
    final Quanda fromJson;
    try {
      fromJson = newQuandaFromRequest();
      if (fromJson == null) {
        appendln("No quanda or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
      checkColumnsToBeUpdated(fromJson);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    Session session = null;
    Transaction txn = null;
    /*
     * the fields with null value in fromJson will update DB columns to NULL
     * since null means either 'not specified' or real NULL. This DB copy can
     * prevent that confusion.
     */
    Quanda fromDB = null;
    try {
      /* get DB copy */
      session  = getSession();
      txn = session.beginTransaction();
      fromDB = (Quanda) session.get(Quanda.class, Long.parseLong(id));
      txn.commit();

      if (fromDB == null) {
        appendln(String.format("Nonexistent quanda ('%d')", id));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (HibernateException e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    try {
      session = getSession();
      txn = session.beginTransaction();

      /* updating status and finalize charge */
      answerQuestion(session, fromJson, fromDB);

      /* save audio */
      saveAudioToObjectStore(fromJson, fromDB);

      session.update(fromDB);
      txn.commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      txn.rollback();
      /* delete answer audio from object store */
      return newServerErrorResponse(e, LOG);
    }
  }

  /**
   * Here's the processing when responder answers the question:
   * <p>
   * 1. update status to 'ANSWERED',
   * </p>
   * <p>
   * if the quanda is not free
   * </p>
   * <p>
   * 2. for asker charged from balance, insert +charged_amount with 'BALANCE'
   * type for responder to Journal table.
   * </p>
   * <p>
   * 3. for asker charged from card, capture charge through Stripe
   * </p>
   * @throws Exception
   */
  private void answerQuestion(
      final Session session,
      final Quanda fromJson,
      final Quanda fromDB) throws Exception {
    /* only update PENDING to ANSWERED */
    if (!fromJson.getStatus().equals(Quanda.QnaStatus.ANSWERED.toString()) ||
        !fromDB.getStatus().equals(Quanda.QnaStatus.PENDING.toString())) {
      return;
    }

    /* set to ANSWERED */
    fromDB.setStatus(fromJson.getStatus());

    /* query qaTransaction */
    final QaTransaction qaTransaction = QaTransactionUtil.getQaTransaction(
        session,
        fromDB.getAsker(),
        QaTransaction.TransType.ASKED.toString(),
        fromDB.getId());

    /* query pending journal */
    final Journal journal = JournalUtil.getPendingJournal(
        session,
        qaTransaction);

    /* insert journals for clearance and responder */
    if (!JournalUtil.pendingJournalCleared(session, journal)) {
      /* insert clearance journal */
      final Journal clearanceJournal = JournalUtil.insertClearanceJournal(
          session,
          journal,
          false);

      /* insert responder journal */
      JournalUtil.insertResponderJournal(
          session,
          clearanceJournal,
          fromDB,
          false);
    }
  }

  private void saveAudioToObjectStore(
      final Quanda fromJson,
      final Quanda fromDB) {
    if (fromJson.getAnswerAudio() != null) {
      fromDB.setAnswerAudio(fromJson.getAnswerAudio());
    }

    final String url = saveAnswerAudio(fromDB);
    if (url != null) {
      fromDB.setAnswerUrl(url);
    }
  }

  private String saveAnswerAudio(final Quanda fromDB) {
    ObjectStoreClient osc = new ObjectStoreClient();
    try {
      return osc.saveAnswerAudio(fromDB);
    } catch (Exception e) {
      LOG.warn(super.stackTraceToString(e));
    }
    return null;
  }

  private FullHttpResponse onCreate() {
    final Quanda fromJson;
    try {
      fromJson = newQuandaFromRequest();
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    final FullHttpResponse resp = verifyQuanda(fromJson);
    if (resp != null) {
      return resp;
    }

    /* set time */
    final Date now = new Date();
    fromJson.setCreatedTime(now);
    fromJson.setUpdatedTime(now);

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      session.save(fromJson);
      txn.commit();
      appendln(toIdJson("id", fromJson.getId()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse verifyQuanda(final Quanda quanda) {
    return verifyQuanda(quanda, getRespBuf());
  }

  static FullHttpResponse verifyQuanda(final Quanda quanda,
      final ByteArrayDataOutput respBuf) {

    if (quanda == null) {
      appendln("No quanda or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(quanda.getAsker())) {
      appendln("No asker specified in quanda", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(quanda.getQuestion())) {
      appendln("No question specified in quanda", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(quanda.getResponder())) {
      appendln("No responder specified in quanda", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (quanda.getRate() == null) {
      appendln("No rate specified in quanda", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (quanda.getAsker().equals(quanda.getResponder())) {
      appendln(String.format(
          "Quanda asker ('%s') can't be the same as responder ('%s')",
          quanda.getAsker(), quanda.getResponder()), respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }

  private Quanda newQuandaFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return Quanda.newQuanda(json);
    }
    return null;
  }
}