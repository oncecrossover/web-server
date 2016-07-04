package com.gibbon.peeq.util;

import java.io.IOException;

import org.apache.commons.lang3.StringUtils;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hdfs.HdfsConfiguration;

import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.db.model.Quanda;

public class ObjectStoreClient {
  private final static String DEFAULT_FS = "hdfs://127.0.0.1:8020";
  private final static String ANSWER_ROOT = "/answers";

  public String saveAnswerAudio(final Quanda quanda) throws IOException {
    if (quanda.getId() > 0 && quanda.getAnswerAudio() != null
        && quanda.getAnswerAudio().length != 0) {
      final String filePath = getAnswerUrl(quanda);
      saveToStore(filePath, quanda.getAnswerAudio());
      return filePath;
    }
    return null;
  }

  public String saveAvatarImage(final Profile profile) throws IOException {
    if (!StringUtils.isBlank(profile.getUid())
        && profile.getAvatarImage() != null
        && profile.getAvatarImage().length != 0) {
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
    return String.format("%s/%s", ANSWER_ROOT, quanda.getId());
  }

  public void saveToStore(final String filePath, final byte[] image)
      throws IOException {
    FSDataOutputStream out = null;
    try {
      HdfsConfiguration conf = new HdfsConfiguration();
      conf.set("fs.defaultFS", DEFAULT_FS);
      FileSystem fs = FileSystem.get(conf);
      Path file = new Path(filePath);
      if (fs.exists(file)) {
        fs.delete(file, true);
      }
      out = fs.create(file);
      out.write(image);
    } catch (IOException e) {
      throw e;
    } finally {
      if (out != null) {
        out.close();
      }
    }
  }
}
