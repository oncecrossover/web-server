package com.wallchain.server.web.handlers;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.common.io.ByteArrayDataOutput;
import com.wallchain.server.db.model.Journal;
import com.wallchain.server.db.model.Profile;
import com.wallchain.server.db.model.QaTransaction;
import com.wallchain.server.db.model.Quanda;
import com.wallchain.server.db.util.JournalUtil;
import com.wallchain.server.db.util.ProfileDBUtil;
import com.wallchain.server.db.util.QaTransactionUtil;
import com.wallchain.server.exceptions.SnoopException;
import com.wallchain.server.util.NotificationUtil;
import com.wallchain.server.util.ObjectStoreClient;
import com.wallchain.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class QuandaWebHandler extends AbastractWebHandler
    implements WebHandler {
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
      WebHandler pwh = new ExpireQuandaWebHandler(
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
   * duration, status, active, isAskerAnonymous are the only DB columns that can
   * be updated by client.
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
          "The fields except duration, status, active, isAskerAnonymous,"
              + " can't be updated.");
    }

    /* allow to update Quanda.status to ANSWERED only */
    if (fromJson.getStatus() != null
        && !fromJson.getStatus().equals(Quanda.QnaStatus.ANSWERED.value())) {
      throw new SnoopException(
          "The status can be changed to ANSWERED only in this API");
    }

    /* allow to update Quanda.active to FALSE only */
    if (fromJson.getActive() != null
        && !fromJson.getActive().equals(Quanda.ActiveStatus.FALSE.value())) {
      throw new SnoopException(
          "The active can be changed to FALSE only in this API");
    }

    /* allow to update Quanda.isAskerAnonymous to TRUE only */
    if (fromJson.getIsAskerAnonymous() != null && !fromJson
        .getIsAskerAnonymous().equals(Quanda.AnonymousStatus.TRUE.value())) {
      throw new SnoopException(
          "The isAskerAnonymous can be changed to TRUE only in this API");
    }
  }

  private FullHttpResponse onUpdate() {
    /* get id */
    Long id = null;
    try {
      id = Long.parseLong(getPathParser().getPathStream().nextToken());
    } catch (NumberFormatException e) {
      appendln("Incorrect id format.");
      return newClientErrorResponse(e, LOG);
    }

    /* get instance from json */
    final Quanda fromJson;
    try {
      fromJson = newInstanceFromRequest(Quanda.class);
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
      fromDB = (Quanda) session.get(Quanda.class, id);
      txn.commit();

      if (fromDB == null) {
        appendln(
            String.format("Nonexistent quanda ('%d')", id));
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

      /* remember status */
      final boolean needSendNotification = isAnsweringQuestion(fromJson,
          fromDB);

      /* process journals and capture charge */
      processJournals4Answer(session, fromJson, fromDB);

      /* save media */
      saveMediaToObjectStore(fromJson, fromDB);

      /* save answer cover */
      saveCoverToObjectStore(fromJson, fromDB);

      /* update columns allowed */
      UpdateColumnsAllowed(session, fromJson, fromDB);

      /* commit all transactions */
      txn.commit();

      /* Send notification */
      if (needSendNotification) {
        sendNotifications(fromDB);
      }

      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      /* TODO: delete answer media from object store */
      return newServerErrorResponse(e, LOG);
    }
  }

  /**
   * Sends notifications if there's a new answer.
   * <p>
   * <ul>
   * <li> send notification to the asker.
   * <li> send notifications to all online users.
   * </ul>
   * <p>
   */
  private void sendNotifications(final Quanda fromDB) {
    final Profile askerProfile = ProfileDBUtil
        .getProfileForNotification(getSession(), fromDB.getAsker(), true);
    final Profile responderProfile = ProfileDBUtil
        .getProfileForNotification(getSession(), fromDB.getResponder(), true);

    sendNotificationToAsker(fromDB, askerProfile, responderProfile);
    asyncSendNotificationToAllUsers(fromDB, askerProfile, responderProfile);
  }

  private void sendNotificationToAsker(final Quanda fromDB,
      final Profile askerProfile, final Profile responderProfile) {
    if (askerProfile != null
        && !StringUtils.isEmpty(askerProfile.getDeviceToken())
        && responderProfile != null) {
      final String title = responderProfile.getFullName()
          + " just answered your question:";
      final String message = fromDB.getQuestion();
      NotificationUtil.sendNotification(title, message,
          askerProfile.getDeviceToken());
    }
  }

  private void asyncSendNotificationToAllUsers(final Quanda fromDB,
      final Profile askerProfile, final Profile responderProfile) {
    final String title = responderProfile != null
        ? responderProfile.getFullName() + " just posted an answer to:"
        : "New answer:";
    final List<Profile> profiles = ProfileDBUtil
        .getAllProfilesWithTokens(getSession(), true);

    ExecutorService executor = Executors.newFixedThreadPool(1);
    for (Profile profile : profiles) {
      if (askerProfile != null && askerProfile.getId() == profile.getId()) {
        /* avoid sending duplicate notification to asker */
        continue;
      }

      executor.submit(new Runnable() {
        @Override
        public void run() {
          final String message = fromDB.getQuestion();
          NotificationUtil.sendNotification(title, message,
              profile.getDeviceToken());
        }
      });
    }
  }

  private boolean isAnsweringQuestion(final Quanda fromJson,
      final Quanda fromDB) {
    return Quanda.QnaStatus.ANSWERED.value().equals(fromJson.getStatus())
        && Quanda.QnaStatus.PENDING.value().equals(fromDB.getStatus());
  }

  private boolean isDeactivatingQuestion(final Quanda fromJson,
      final Quanda fromDB) {
    return Quanda.ActiveStatus.FALSE.value().equals(fromJson.getActive())
        && Quanda.ActiveStatus.TRUE.value().equals(fromDB.getActive());
  }

  private boolean isAnonymizingAsker(final Quanda fromJson,
      final Quanda fromDB) {
    return Quanda.AnonymousStatus.TRUE.value()
        .equals(fromJson.getIsAskerAnonymous())
        && Quanda.AnonymousStatus.FALSE.value()
            .equals(fromDB.getIsAskerAnonymous());
  }

  private void UpdateColumnsAllowed(
      final Session session,
      final Quanda fromJson,
      final Quanda fromDB) {

    boolean needUpdate = false;
    if (isAnsweringQuestion(fromJson, fromDB)) {
      /* answer it */
      fromDB.setStatus(Quanda.QnaStatus.ANSWERED.value());
      fromDB.setAnsweredTime(DateTime.now().toDate());
      needUpdate = true;
    }

    if (isDeactivatingQuestion(fromJson, fromDB)) {
      /* deactivate it */
      fromDB.setActive(Quanda.ActiveStatus.FALSE.value());
      needUpdate = true;
    }

    if (fromJson.getDuration() > 0) {
      fromDB.setDuration(fromJson.getDuration());
      needUpdate = true;
    }

    if (isAnonymizingAsker(fromJson, fromDB)) {
      fromDB.setIsAskerAnonymous(Quanda.AnonymousStatus.TRUE.value());
      needUpdate = true;
    }

    if (needUpdate) {
      session.update(fromDB);
    }
  }

  /**
   * Here's the processing when responder answers the question:
   * <p>
   * 1. update status to 'ANSWERED', if the quanda is not free
   * </p>
   * <p>
   * 2. for asker charged from balance, insert +charged_amount with 'BALANCE'
   * type for responder to Journal table.
   * </p>
   * @throws Exception
   */
  private void processJournals4Answer(
      final Session session,
      final Quanda fromJson,
      final Quanda fromDB) throws Exception {
    /* only update PENDING to ANSWERED */
    if (!isAnsweringQuestion(fromJson, fromDB)) {
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
        QaTransaction.TransType.ASKED.value(),
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

    if (quanda.getAsker() == null) {
      appendln("No asker specified in quanda", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(quanda.getQuestion())) {
      appendln("No question specified in quanda", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (quanda.getResponder() == null) {
      appendln("No responder specified in quanda", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (quanda.getRate() == null) {
      appendln("No rate specified in quanda", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }
}