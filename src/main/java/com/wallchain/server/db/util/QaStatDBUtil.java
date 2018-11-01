package com.wallchain.server.db.util;

import java.util.List;
import java.util.Map;

import org.assertj.core.util.Lists;
import org.hibernate.Session;
import org.hibernate.type.IntegerType;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.Type;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.collect.Maps;
import com.wallchain.server.model.QaStat;

public class QaStatDBUtil {

  private static final Logger LOG = LoggerFactory
      .getLogger(QaStatDBUtil.class);

  public static List<QaStat> getQaStats(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction) {

    List<QaStat> resultList = Lists.newArrayList();

    /* get and uid and quandaId list */
    Long uid = 0L;
    List<String> quandaIdList = Lists.newArrayList();
    for (String key : params.keySet()) {
      switch (key) {
      case "uid":
        try {
          uid = Long.parseLong(params.get(key).get(0));
        } catch (Throwable t) {
          LOG.warn(t.toString());
        }
        break;
      case "quandaId":
        quandaIdList = params.get(key);
        break;
      default:
        break;
      }
    }

    /* queury QaStat by quandaId and merge it to final list */
    for (String id : quandaIdList) {
      Long quandaId = 0L;
      try {
        quandaId = Long.parseLong(id);
      } catch (Throwable t) {
        LOG.warn(t.toString());
        continue;
      }

      final String sql = buildSql4QaStat(quandaId, uid);
      final List<QaStat> list = DBUtil.getEntitiesByQuery(QaStat.class,
          session, sql, getScalars(), newTransaction);
      if (list != null) {
        resultList.addAll(list);
      }
    }

    return resultList;
  }

  private static String buildSql4QaStat(final Long quandaId, final Long uid) {

    final String select = "SELECT"
        + " (SELECT %d) AS id,"
        + " (SELECT COUNT(S.quandaId) FROM Snoop AS S WHERE S.quandaId = %d) AS snoops,"
        + " COUNT(CASE WHEN T.quandaId = %d AND T.upped = 'TRUE' THEN 1 END) AS thumbups,"
        + " COUNT(CASE WHEN T.quandaId = %d AND T.downed = 'TRUE' THEN 1 END) AS thumbdowns,"
        + " IFNULL((SELECT upped FROM Thumb WHERE uid = %d AND quandaId = %d), 'FALSE') AS thumbupped,"
        + " IFNULL((SELECT downed FROM Thumb WHERE uid = %d AND quandaId = %d), 'FALSE') AS thumbdowned"
        + " FROM Thumb AS T";

    if (quandaId == null ) {
      return select +
          /* simulate no quanda id specified */
          " WHERE 1 = 0";
    } else {
      return String.format(select, quandaId, quandaId, quandaId, quandaId, uid, quandaId, uid, quandaId);
    }
  }

  private static Map<String, Type> getScalars() {
    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("id", new LongType());
    scalars.put("snoops", new IntegerType());
    scalars.put("thumbups", new IntegerType());
    scalars.put("thumbdowns", new IntegerType());
    scalars.put("thumbupped", new StringType());
    scalars.put("thumbdowned", new StringType());
    return scalars;
  }
}
