package com.gibbon.peeq.util;

import static org.junit.Assert.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.model.Profile;

public class TestObjectStoreClient {

  private static final Logger LOG = LoggerFactory
      .getLogger(TestObjectStoreClient.class);

  @Test(timeout = 60000)
  public void testImageSave() throws IOException {
    final String localPath = "src/main/resources/com/gibbon/peeq/images/arnold.jpg";
    final File file = new File(localPath);
    final byte[] fileContent = Files.readAllBytes(file.toPath());
    final ObjectStoreClient osc = new ObjectStoreClient();
    final String osPath = "/arnold@gmail.com/celebrity.jpeg";
    try {
      osc.saveImage(osPath, fileContent);
    } catch (Exception e) {
      assertTrue("IOException happens when HDFS is properly set.",
          e instanceof IOException);
    }
  }

  // @Test(timeout = 60000)
  @Test
  public void testProfileAvatarSave() throws IOException {
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
}
