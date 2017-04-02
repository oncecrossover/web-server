package com.snoop.server.util;

import static org.junit.Assert.*;

import java.io.File;
import java.nio.file.Files;
import java.util.Random;

import org.junit.BeforeClass;
import org.junit.Test;

import com.snoop.server.db.model.Profile;
import com.snoop.server.db.model.Quanda;
import com.snoop.server.util.ObjectStoreClient;

public class TestObjectStoreClient {

  private Random r = new Random(System.currentTimeMillis());
  private static final String PREFIX = "https://s3-us-west-2.amazonaws.com/com.snoop.server.test";
 
  @BeforeClass
  public static void setupClass() {
    ObjectStoreClient.setS3UriPrefix(PREFIX);
  }

  @Test(timeout = 60000)
  public void testReadFromStore() throws Exception {
    final String localPath = "src/main/resources/com/snoop/server/images/matt.jpg";
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
    final String localPath = "src/main/resources/com/snoop/server/images/arnold.jpg";
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
    final String localPath = "src/main/resources/com/snoop/server/images/kobe.jpg";
    final File file = new File(localPath);
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    assertNotNull(fileContent);

    final ObjectStoreClient osc = new ObjectStoreClient();
    final Long uid = r.nextLong();
    final Profile profile = new Profile();
    profile.setUid(uid).setAvatarImage(fileContent);

    osc.saveAvatarImage(profile);
    final String avatarUrl = osc.getAvatarS3Url(profile);
    assertNotNull(avatarUrl);

    final byte[] readContent = osc.readFromStore(avatarUrl);
    assertNotNull(readContent);
    assertEquals(fileContent.length, readContent.length);
  }

  @Test(timeout = 60000)
  public void testLoadSaveAnswerMedia() throws Exception {
    final String localPath = "src/main/resources/com/snoop/server/images/chow.jpg";
    final File file = new File(localPath);
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    assertNotNull(fileContent);

    final ObjectStoreClient osc = new ObjectStoreClient();
    final Quanda quanda = new Quanda();
    quanda.setId(1010L).setAnswerMedia(fileContent);

    osc.saveAnswerMedia(quanda);
    final String answerUrl = osc.getAnswerVideoS3Url(quanda);
    assertNotNull(answerUrl);

    final byte[] readContent = osc.readFromStore(answerUrl);
    assertNotNull(readContent);
    assertEquals(fileContent.length, readContent.length);
  }
}
