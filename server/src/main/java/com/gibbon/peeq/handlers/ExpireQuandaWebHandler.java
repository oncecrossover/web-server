package com.gibbon.peeq.handlers;

import java.util.Date;
import java.util.List;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gibbon.peeq.db.model.Journal;
import com.gibbon.peeq.db.model.QaTransaction;
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.db.util.JournalUtil;
import com.gibbon.peeq.db.util.QaTransactionUtil;
import com.gibbon.peeq.db.util.QuandaUtil;
import com.gibbon.peeq.util.ResourcePathParser;
import com.gibbon.peeq.util.StripeUtil;
import com.google.common.collect.Lists;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class ExpireQuandaWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(ExpireQuandaWebHandler.class);

  public ExpireQuandaWebHandler(
      ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  private static class QaTuple {
    private Long id;
    private String status;
    private Date createdTime;
    private String error;

    public QaTuple(
        final Long id,
        final String status,
        final Date createdTime) {
      this(id, status, createdTime, null);
    }

    public QaTuple(
        final Long id,
        final String status,
        final Date createdTime,
        final String error) {
      this.id = id;
      this.status = status;
      this.createdTime = createdTime;
      this.error = error;
    }

    public Long getId() {
      return id;
    }
    public QaTuple setId(final Long id) {
      this.id = id;
      return this;
    }

    public String getStatus() {
      return status;
    }
    public QaTuple setStatus(final String status) {
      this.status = status;
      return this;
    }

    public Date getCreatedTime() {
      return createdTime;
    }
    public QaTuple setCreatedTime(final Date createdTime) {
      this.createdTime = createdTime;
      return this;
    }

    public String getError() {
      return error;
    }
    public QaTuple setError(final String error) {
      this.error = error;
      return this;
    }

    @Override
    public String toString() {
      try {
        return toJsonStr();
      } catch (JsonProcessingException e) {
        return "";
      }
    }

    public String toJsonStr() throws JsonProcessingException {
      ObjectMapper mapper = new ObjectMapper();
      return mapper.writeValueAsString(this);
    }
  }

  private FullHttpResponse onCreate() {
    Session session = null;
    Transaction txn = null;
    List<Quanda> toDoList = null;
    List<QaTuple> doneList = Lists.newArrayList();
    List<QaTuple> failedList = Lists.newArrayList();

    try {
      session = getSession();
      txn = session.beginTransaction();
      toDoList = QuandaUtil.getExpiredQuandas(session);
      txn.commit();
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }

    /* expire quandas */
    for (Quanda quanda : toDoList) {
      try {
        session = getSession();
        txn = session.beginTransaction();

        /* process journals and refund charge */
        processJournals4Expire(session, quanda);

        /* expire */
        expireQuanda(session, quanda);

        /* commit all transactions */
        txn.commit();

        doneList.add(new QaTuple(
            quanda.getId(),
            quanda.getStatus(),
            quanda.getCreatedTime()));
      } catch (Exception e) {
        txn.rollback();
        failedList.add(new QaTuple(
            quanda.getId(),
            quanda.getStatus(),
            quanda.getCreatedTime(),
            stackTraceToString(e)));
      }
    }

    appendln("DONE:");
    appendln(listToJsonString(doneList));
    appendln("FAILED:");
    appendln(listToJsonString(failedList));
    return newResponse(HttpResponseStatus.CREATED);
  }

  private void expireQuanda(
      final Session session,
      final Quanda quanda) {
    if (!Quanda.QnaStatus.PENDING.toString().equals(quanda.getStatus())) {
      return;
    }

    /* set status */
    quanda.setStatus(Quanda.QnaStatus.EXPIRED.toString());

    /* query DB copy to avoid updating columns to NULL if the fields are null */
    final Quanda retInstance = (Quanda) session.get(
        Quanda.class,
        quanda.getId());
    retInstance.setStatus(quanda.getStatus());

    /* update status */
    session.update(retInstance);
  }

  private void processJournals4Expire(
      final Session session,
      final Quanda fromDB) throws Exception {
    /* only update PENDING to EXPIRED */
    if (!Quanda.QnaStatus.PENDING.toString().equals(fromDB.getStatus())) {
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

    /* insert journals for clearance and refund */
    if (!JournalUtil.pendingJournalCleared(session, pendingJournal)) {
      /* insert clearance journal */
      final Journal clearanceJournal = JournalUtil.insertClearanceJournal(
          session,
          pendingJournal);

      /* insert refund journal */
      JournalUtil.insertRefundJournal(
          session,
          clearanceJournal,
          fromDB);

      /* refund charge */
      if (Journal.JournalType.CARD.toString().equals(pendingJournal.getType())) {
        StripeUtil.refundCharge(pendingJournal.getChargeId());
      }
    }
  }
}
