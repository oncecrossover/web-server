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
  public void testSaveToStore() throws IOException {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/arnold.jpg";
    final File file = new File(localPath);
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    final ObjectStoreClient osc = new ObjectStoreClient();
    final String osPath = "/arnold@gmail.com/celebrity.jpeg";
    try {
      osc.saveToStore(osPath, fileContent);
    } catch (Exception e) {
      assertTrue("IOException happens when HDFS is properly set.",
          e instanceof IOException);
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

    try {
      String avatarUrl = osc.saveAvatarImage(profile);
      assertEquals("/kobe@gmail.com/avatar", avatarUrl);
    } catch (Exception e) {
      assertTrue("IOException happens when HDFS is properly set.",
          e instanceof IOException);
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

    try {
      String answerUrl = osc.saveAnswerAudio(quanda);
      assertEquals("/answers/1010", answerUrl);
    } catch (Exception e) {
      assertTrue("IOException happens when HDFS is properly set.",
          e instanceof IOException);
    }
  }
}
