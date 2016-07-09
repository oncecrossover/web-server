package com.gibbon.peeq.util;

import org.apache.commons.lang3.StringUtils;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hdfs.HdfsConfiguration;

import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.db.model.Quanda;

public class ObjectStoreClient {
  private final static String DEFAULT_FS = "hdfs://127.0.0.1:8020";
  private final static String ANSWER_ROOT = "/answers";
  private final static HdfsConfiguration conf = new HdfsConfiguration();
  static {
    conf.set("fs.defaultFS", DEFAULT_FS);
  }

  public byte[] readAnswerAudio(final String answerUrl) throws Exception {
    if (StringUtils.isBlank(answerUrl)) {
      return null;
    }

    return readFromStore(answerUrl);
  }

  public String saveAnswerAudio(final Quanda quanda) throws Exception {
    if (quanda.getId() > 0 && quanda.getAnswerAudio() != null
        && quanda.getAnswerAudio().length > 0) {
      final String filePath = getAnswerUrl(quanda);
      saveToStore(filePath, quanda.getAnswerAudio());
      return filePath;
    }
    return null;
  }


  public byte[] readAvatarImage(final String avatarUrl) throws Exception {
    if (StringUtils.isBlank(avatarUrl)) {
      return null;
    }

    return readFromStore(avatarUrl);
  }

  public String saveAvatarImage(final Profile profile) throws Exception {
    if (!StringUtils.isBlank(profile.getUid())
        && profile.getAvatarImage() != null
        && profile.getAvatarImage().length > 0) {
      final String filePath = getAvatarUrl(profile);
      saveToStore(filePath, profile.getAvatarImage());
      return filePath;
    }

    return null;
  }

  private String getAvatarUrl(final Profile profile) {
    return String.format("/%s/%s", profile.getUid(), "avatar");
  }

  private String getAnswerUrl(final Quanda quanda) {
    return String.format("%s/%d", ANSWER_ROOT, quanda.getId());
  }

  public byte[] readFromStore(final String filePath) throws Exception {
    if (StringUtils.isBlank(filePath)) {
      return null;
    }

    FSDataInputStream in = null;
    try {
      final FileSystem fs = FileSystem.get(conf);
      final Path fsPath = new Path(filePath);
      if (!fs.exists(fsPath)) {
        return null;
      }
      in = fs.open(fsPath);
      final long length = fs.getFileStatus(fsPath).getLen();
      final byte[] ba = new byte[(int) length];
      in.readFully(ba);
      return ba;
    } catch (Exception e) {
      throw e;
    } finally {
      if (in != null) {
        in.close();
      }
    }
  }

  public void saveToStore(final String filePath, final byte[] image)
      throws Exception {
    FSDataOutputStream out = null;
    try {
      FileSystem fs = FileSystem.get(conf);
      Path file = new Path(filePath);
      if (fs.exists(file)) {
        fs.delete(file, true);
      }
      out = fs.create(file);
      out.write(image);
    } catch (Exception e) {
      throw e;
    } finally {
      if (out != null) {
        out.close();
      }
    }
  }
}
