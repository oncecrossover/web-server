package com.gibbon.peeq.handlers;

import java.io.IOException;

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
import com.gibbon.peeq.db.util.JournalUtil;
import com.gibbon.peeq.db.util.QaTransactionUtil;
import com.gibbon.peeq.exceptions.SnoopException;
import com.gibbon.peeq.util.ObjectStoreClient;
import com.gibbon.peeq.util.ResourcePathParser;
import com.gibbon.peeq.util.StripeUtil;
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

  public QuandaWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onGet();
  }

  @Override
  protected FullHttpResponse handleCreation() {
    /* get controller */
    final String controller = getPathParser().getPathStream().nextToken();

    /* expire */
    if ("expire".equals(controller)) {
      PeeqWebHandler pwh = new ExpireQuandaWebHandler(
          getPathParser(),
          getRespBuf(),
          getHandlerContext(),
          getRequest());
      return pwh.handle();
    }

    appendln(
        String.format("Unsupported controller resources: '%s'" + controller));
    return newResponse(HttpResponseStatus.BAD_REQUEST);
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdate();
  }

  private FullHttpResponse onGet() {
    /* get id */
    final String id = getPathParser().getPathStream().nextToken();

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
   * Quanda.status, Quanda.active, Quanda.answerUrl (as a result of
   * Quanda.answerMedia) and Quanda.answerCoverUrl (as a result of
   * Quanda.answerCover) are the only DB columns that can be updated by client.
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
        fromJson.getAnswerCoverUrl() != null ||
        fromJson.getCreatedTime() != null ||
        fromJson.getUpdatedTime() != null ||
        fromJson.getSnoops() != null) {
      throw new SnoopException(
          "The fields except answerMedia, answerCover,"
              + " status and active can't be updated");
    }

    /* allow to update Quanda.status to ANSWERED only */
    if (fromJson.getStatus() != null
        && !fromJson.getStatus().equals(Quanda.QnaStatus.ANSWERED.toString())) {
      throw new SnoopException(
          "The status can be changed to ANSWERED only in this API");
    }

    /* allow to update Quanda.active to FALSE only */
    if (fromJson.getActive() != null
        && !fromJson.getActive().equals(Quanda.LiveStatus.FALSE.toString())) {
      throw new SnoopException(
          "The status can be changed to ANSWERED only in this API");
    }
  }


  private FullHttpResponse onUpdate() {
    /* get id */
    final String id = getPathParser().getPathStream().nextToken();

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
        appendln(
            String.format("Nonexistent quanda ('%d')", Long.parseLong(id)));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    try {
      session = getSession();
      txn = session.beginTransaction();

      /* process journals and capture charge */
      processJournals4Answer(session, fromJson, fromDB);

      /* save media */
      saveMediaToObjectStore(fromJson, fromDB);

      /* save answer cover */
      saveCoverToObjectStore(fromJson, fromDB);

      /* update */
      UpdateStatusActive(session, fromJson, fromDB);

      /* commit all transactions */
      txn.commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      /* TODO: delete answer media from object store */
      return newServerErrorResponse(e, LOG);
    }
  }

  private void UpdateStatusActive(
      final Session session,
      final Quanda fromJson,
      final Quanda fromDB) {

    boolean needUpdate = false;
    if (Quanda.QnaStatus.ANSWERED.toString().equals(fromJson.getStatus()) &&
        Quanda.QnaStatus.PENDING.toString().equals(fromDB.getStatus())) {
      /* answer it */
      fromDB.setStatus(Quanda.QnaStatus.ANSWERED.toString());
      needUpdate = true;
    }

    if (Quanda.LiveStatus.FALSE.value().equals(fromJson.getActive()) &&
        Quanda.LiveStatus.TRUE.value().equals(fromDB.getActive())) {
      /* deactivate it */
      fromDB.setActive(Quanda.LiveStatus.FALSE.toString());
      needUpdate = true;
    }

    if (fromJson.getDuration() > 0) {
      fromDB.setDuration(fromJson.getDuration());
      needUpdate = true;
    }

    if (needUpdate) {
      session.update(fromDB);
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
  private void processJournals4Answer(
      final Session session,
      final Quanda fromJson,
      final Quanda fromDB) throws Exception {
    /* only update PENDING to ANSWERED */
    if (!Quanda.QnaStatus.ANSWERED.toString().equals(fromJson.getStatus()) ||
        !Quanda.QnaStatus.PENDING.toString().equals(fromDB.getStatus())) {
      return;
    }

    /* free quanda */
    if (fromDB.getRate() <= 0) {
      return;
    }

    /* query qaTransaction */
    final QaTransaction qaTransaction = QaTransactionUtil.getQaTransaction(
        session,
        fromDB.getAsker(),
        QaTransaction.TransType.ASKED.toString(),
        fromDB.getId());

    /* query pending journal */
    final Journal pendingJournal = JournalUtil.getPendingJournal(
        session,
        qaTransaction);

    /* insert journals for clearance and responder */
    if (!JournalUtil.pendingJournalCleared(session, pendingJournal)) {
      /* insert clearance journal */
      final Journal clearanceJournal = JournalUtil.insertClearanceJournal(
          session,
          pendingJournal);

      /* insert responder journal */
      JournalUtil.insertResponderJournal(
          session,
          clearanceJournal,
          fromDB);

      /* capture charge */
      if (Journal.JournalType.CARD.toString()
          .equals(pendingJournal.getType())) {
        StripeUtil.captureCharge(pendingJournal.getChargeId());
      }
    }
  }

  private void saveMediaToObjectStore(
      final Quanda fromJson,
      final Quanda fromDB) {
    if (fromJson.getAnswerMedia() != null) {
      fromDB.setAnswerMedia(fromJson.getAnswerMedia());

      final String url = saveAnswerMedia(fromDB);
      if (url != null) {
        fromDB.setAnswerUrl(url);
      }
    }
  }

  private String saveAnswerMedia(final Quanda fromDB) {
    ObjectStoreClient osc = new ObjectStoreClient();
    try {
      return osc.saveAnswerMedia(fromDB);
    } catch (Exception e) {
      LOG.warn(super.stackTraceToString(e));
    }
    return null;
  }

  private void saveCoverToObjectStore(
      final Quanda fromJson,
      final Quanda fromDB) {
    if (fromJson.getAnswerCover() != null) {
      fromDB.setAnswerCover(fromJson.getAnswerCover());

      final String url = saveAnswerCover(fromDB);
      if (url != null) {
        fromDB.setAnswerCoverUrl(url);
      }
    }
  }

  private String saveAnswerCover(final Quanda fromDB) {
    final ObjectStoreClient osc = new ObjectStoreClient();
    try {
      return osc.saveAnswerCover(fromDB);
    } catch (Exception e) {
      LOG.warn(super.stackTraceToString(e));
    }
    return null;
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