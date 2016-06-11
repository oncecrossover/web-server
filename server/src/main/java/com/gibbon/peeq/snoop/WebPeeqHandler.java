package com.gibbon.peeq.snoop;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpRequest;
import static io.netty.handler.codec.http.HttpMethod.GET;
import static io.netty.handler.codec.http.HttpMethod.POST;
import static io.netty.handler.codec.http.HttpMethod.DELETE;
import static io.netty.handler.codec.http.HttpMethod.PUT;

import java.io.IOException;
import java.util.Date;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.Session;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.db.util.HibernateUtil;

public class WebPeeqHandler {
  private static final Logger LOG = LoggerFactory
      .getLogger(WebPeeqHandler.class);
  private Session session = HibernateUtil.getSessionFactory()
      .getCurrentSession();
  private ParameterParser params;
  private StrBuilder buf;

  public WebPeeqHandler(ParameterParser paramParser, StrBuilder buf) {
    params = paramParser;
    this.buf = buf;
  }

  public void handle(ChannelHandlerContext ctx, HttpRequest req)
      throws Exception {
    String op = params.getOp();
    HttpMethod method = req.method();
    if (ParameterParser.PUT_USER.equalsIgnoreCase(op) && method == POST) {
      onPutUser(ctx);
    } else if (ParameterParser.GET_USER.equalsIgnoreCase(op) && method == GET) {
      onGetUser(ctx);
    } else if (ParameterParser.RM_USER.equalsIgnoreCase(op) && method == DELETE) {
      onRmUser(ctx);
    } else if (ParameterParser.UPD_USER.equalsIgnoreCase(op) && method == PUT) {
      onUpdUser(ctx);
    } else {
      throw new IllegalArgumentException(String
          .format("Invalid operation %s, forgot HTTP options GET/POST?", op));
    }
  }

  private void onPutUser(ChannelHandlerContext ctx) throws Exception {
    User user = null;
    try {
      user = createUser();
      session.beginTransaction();
      session.save(user);
      session.getTransaction().commit();
      buf.appendln(okStatus());
      buf.appendln(getMsg("putuser", user));
    } catch (Exception e) {
      session.getTransaction().rollback();
      buf.appendln(errStatus());
      buf.appendln(getMsg("putuser", user));
      throw e;
    }
  }

  private void onGetUser(ChannelHandlerContext ctx) throws Exception {
    User user = null;
    try {
      String uid = params.getUid();
      if (StringUtils.isBlank(uid)) {
        throw new IOException(
            new IllegalArgumentException("Missing parameter uid"));
      }
      session.beginTransaction();
      user = (User) session.get(User.class, uid);
      session.getTransaction().commit();
      buf.appendln(okStatus());
      buf.appendln(getMsg("getuser", user));
      buf.appendln(String.format("USERJASON = %s", user.toJson()));
    } catch (Exception e) {
      session.getTransaction().rollback();
      buf.appendln(errStatus());
      buf.appendln(getMsg("getuser", user));
      throw e;
    }
  }

  private void onRmUser(ChannelHandlerContext ctx) throws Exception {
    User user = null;
    try {
      String uid = params.getUid();
      if (StringUtils.isBlank(uid)) {
        throw new IOException(
            new IllegalArgumentException("Missing parameter uid"));
      }

      user = new User();
      user.setUid(uid);
      session.beginTransaction();
      session.delete(user);
      session.getTransaction().commit();
      buf.appendln(okStatus());
      buf.appendln(getMsg("rmuser", user));
    } catch (Exception e) {
      session.getTransaction().rollback();
      buf.appendln(errStatus());
      buf.appendln(getMsg("rmuser", user));
      throw e;
    }
  }

  private void onUpdUser(ChannelHandlerContext ctx) throws Exception {
    User user = null;
    try {
      user = createUser();
      session.beginTransaction();
      session.update(user);
      session.getTransaction().commit();
      buf.appendln(okStatus());
      buf.appendln(getMsg("upduser", user));
    } catch (Exception e) {
      session.getTransaction().rollback();
      buf.appendln(errStatus());
      buf.appendln(getMsg("upduser", user));
      throw e;
    }
  }

  private String okStatus() {
    return "OPSTATUS = OK";
  }

  private String errStatus() {
    return "OPSTATUS = ERR";
  }

  private String getMsg(String op, User user) {
    return String.format("%s: User(%s)", op,
        user != null ? user.getUid() : "undefined");
  }

  private User createUser() {
    String uid = params.getUid();
    String firstName = params.getFirstName();
    String middleName = params.getMiddleName();
    String lastName = params.getLastName();
    String pwd = params.getPwd();
    if (StringUtils.isBlank(uid) || StringUtils.isBlank(pwd)) {
      throw new IllegalArgumentException("Missing parameter uid or pwd");
    }

    User user = new User();
    user.setUid(uid);
    user.setFirstName(firstName);
    user.setMiddleName(middleName);
    user.setLastName(lastName);
    user.setPwd(pwd);
    user.setInsertTime(new Date());
    return user;
  }
}
