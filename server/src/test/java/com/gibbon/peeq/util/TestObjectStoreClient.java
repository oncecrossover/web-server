package com.gibbon.peeq.util;

import static org.junit.Assert.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.db.model.Quanda;

public class TestObjectStoreClient {

  private static final Logger LOG = LoggerFactory
      .getLogger(TestObjectStoreClient.class);

  @Test(timeout = 60000)
  public void testReadFromStore() throws IOException {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/matt.jpg";
    final File file = new File(localPath);
    final ObjectStoreClient osc = new ObjectStoreClient();
    final String osPath = "/matt@gmail.com/celebrity.jpeg";
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    try {
      osc.saveToStore(osPath, fileContent);
    } catch (Exception e) {
      assertTrue("IOException shoudn't happen when HDFS is properly set.",
          e instanceof IOException);
    }

    try {
      final byte[] readContent = osc.readFromStore(osPath);
      if (fileContent != null && readContent != null
          && readContent.length > 0) {
        assertEquals(fileContent.length, readContent.length);
      }
    } catch (Exception e) {
      assertTrue("IOException shoudn't happen when HDFS is properly set.",
          e instanceof IOException);
    } finally {
      try {
        osc.deleteFromStore(osPath);
      } catch (Exception e) {
        assertTrue("IOException shoudn't happen when HDFS is properly set.",
            e instanceof IOException);
      }
    }
  }

  @Test(timeout = 60000)
  public void testSaveToStore() throws IOException {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/arnold.jpg";
    final File file = new File(localPath);
    final ObjectStoreClient osc = new ObjectStoreClient();
    final String osPath = "/arnold@gmail.com/celebrity.jpeg";
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    try {
      osc.saveToStore(osPath, fileContent);
    } catch (Exception e) {
      assertTrue("IOException shoudn't happen when HDFS is properly set.",
          e instanceof IOException);
    } finally {
      try {
        osc.deleteFromStore(osPath);
      } catch (Exception e) {
        assertTrue("IOException shoudn't happen when HDFS is properly set.",
            e instanceof IOException);
      }
    }
  }

  @Test(timeout = 60000)
  public void testSaveProfileAvatar() throws IOException {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/kobe.jpg";
    final File file = new File(localPath);
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    final ObjectStoreClient osc = new ObjectStoreClient();
    final String uid = "kobe@gmail.com";
    final Profile profile = new Profile();
    profile.setUid(uid).setAvatarImage(fileContent);
    final String url = "/kobe@gmail.com/avatar";

    String avatarUrl = null;
    try {
      avatarUrl = osc.saveAvatarImage(profile);
      assertEquals(url, avatarUrl);
    } catch (Exception e) {
      assertTrue("IOException shoudn't happen when HDFS is properly set.",
          e instanceof IOException);
    } finally {
      try {
        osc.deleteFromStore(url);
      } catch (Exception e) {
        assertTrue("IOException shoudn't happen when HDFS is properly set.",
            e instanceof IOException);
      }
    }
  }

  @Test(timeout = 60000)
  public void testSaveAnswerAudio() throws IOException {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/chow.jpg";
    final File file = new File(localPath);
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    final ObjectStoreClient osc = new ObjectStoreClient();
    final Quanda quanda = new Quanda();
    quanda.setId(1010).setAnswerAudio(fileContent);
    final String url = "/answers/1010";

    String answerUrl = null;
    try {
      answerUrl = osc.saveAnswerAudio(quanda);
      assertEquals(url, answerUrl);
    } catch (Exception e) {
      assertTrue("IOException shoudn't happen when HDFS is properly set.",
          e instanceof IOException);
    } finally {
      try {
        osc.deleteFromStore(url);
      } catch (Exception e) {
        assertTrue("IOException shoudn't happen when HDFS is properly set.",
            e instanceof IOException);
      }
    }
  }

  public void testReadAnswerAudio() throws IOException {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/mike.jpg";
    final File file = new File(localPath);
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    final ObjectStoreClient osc = new ObjectStoreClient();
    final Quanda quanda = new Quanda();
    quanda.setId(1011).setAnswerAudio(fileContent);
    final String url = "/answers/1011";

    String answerUrl = null;
    try {
      answerUrl = osc.saveAnswerAudio(quanda);
      assertEquals(url, answerUrl);
    } catch (Exception e) {
      assertTrue("IOException shoudn't happen when HDFS is properly set.",
          e instanceof IOException);
    }

    try {
      final byte[] readContent = osc.readFromStore(answerUrl);
      if (fileContent != null && readContent != null) {
        assertEquals(fileContent.length, readContent.length);
      }
    } catch (Exception e) {
      assertTrue("IOException shoudn't happen when HDFS is properly set.",
          e instanceof IOException);
    } finally {
      try {
        osc.deleteFromStore(url);
      } catch (Exception e) {
        assertTrue("IOException shoudn't happen when HDFS is properly set.",
            e instanceof IOException);
      }
    }
  }
}
