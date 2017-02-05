package com.gibbon.peeq.util;

import static org.junit.Assert.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.UUID;

import org.junit.BeforeClass;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.amazonaws.AmazonServiceException;
import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.db.model.Quanda;

public class TestObjectStoreClient {

  private static final String PREFIX = "https://s3-us-west-2.amazonaws.com/com.snoop.server.test";
 
  @BeforeClass
  public static void setupClass() {
    ObjectStoreClient.setPrefix(PREFIX);
  }

  @Test(timeout = 60000)
  public void testReadFromStore() throws Exception {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/matt.jpg";
    final File file = new File(localPath);
    final ObjectStoreClient osc = new ObjectStoreClient();
    final String url = String.format("%s/%s", PREFIX,
        "users/matt@gmail.com/celebrity.jpeg");
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    assertNotNull(fileContent);

    osc.writeToStore(url, fileContent);

    final byte[] readContent = osc.readFromStore(url);
    assertNotNull(readContent);
    assertEquals(fileContent.length, readContent.length);
  }

  @Test(timeout = 60000)
  public void testSaveToStore() throws Exception {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/arnold.jpg";
    final File file = new File(localPath);
    final ObjectStoreClient osc = new ObjectStoreClient();
    final String url = String.format("%s/%s", PREFIX,
        "users/arnold@gmail.com/celebrity.jpeg");
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    assertNotNull(fileContent);

    osc.writeToStore(url, fileContent);

    final byte[] readContent = osc.readFromStore(url);
    assertNotNull(readContent);
    assertEquals(fileContent.length, readContent.length);
  }

  @Test(timeout = 60000)
  public void testLoadSaveProfileAvatar() throws Exception {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/kobe.jpg";
    final File file = new File(localPath);
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    assertNotNull(fileContent);

    final ObjectStoreClient osc = new ObjectStoreClient();
    final String uid = UUID.randomUUID() + "@test.com";
    final Profile profile = new Profile();
    profile.setUid(uid).setAvatarImage(fileContent);

    final String avatarUrl = osc.saveAvatarImage(profile);
    assertNotNull(avatarUrl);

    final byte[] readContent = osc.readFromStore(avatarUrl);
    assertNotNull(readContent);
    assertEquals(fileContent.length, readContent.length);
  }

  @Test(timeout = 60000)
  public void testLoadSaveAnswerMedia() throws Exception {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/chow.jpg";
    final File file = new File(localPath);
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    assertNotNull(fileContent);

    final ObjectStoreClient osc = new ObjectStoreClient();
    final Quanda quanda = new Quanda();
    quanda.setId(1010L).setAnswerMedia(fileContent);

    final String answerUrl = osc.saveAnswerMedia(quanda);
    assertNotNull(answerUrl);

    final byte[] readContent = osc.readFromStore(answerUrl);
    assertNotNull(readContent);
    assertEquals(fileContent.length, readContent.length);
  }
}
