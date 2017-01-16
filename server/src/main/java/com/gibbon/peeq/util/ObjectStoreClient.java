package com.gibbon.peeq.util;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.apache.commons.lang3.StringUtils;
import org.mortbay.log.Log;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.amazonaws.AmazonClientException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.AmazonS3URI;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.db.model.Quanda;
import com.google.common.io.ByteStreams;

public class ObjectStoreClient {
  private static final String USER_ROOT = "com.snoop.server.users";
  private static final String ANSWER_ROOT = "com.snoop.server.answers";
  private static final String PREFIX = "https://s3-us-west-1.amazonaws.com";
  private static AmazonS3 s3 = null;

  static {
    try {
      final AWSCredentials credentials = new ProfileCredentialsProvider()
          .getCredentials();
      s3 = new AmazonS3Client(credentials);
      s3.setRegion(Region.getRegion(Regions.US_WEST_2));
    } catch (Exception e) {
      throw new AmazonClientException(
          "Cannot load the credentials from the credential profiles file. "
              + "Please make sure that your credentials file is at the correct "
              + "location (~/.aws/credentials), and is in valid format.",
          e);
    }
  }

  public byte[] readAnswerCover(final String answerCoverUrl) throws Exception {
    return readByUrl(answerCoverUrl);
  }

  public byte[] readAnswerMedia(final String answerUrl) throws Exception {
    return readByUrl(answerUrl);
  }

  public String saveAnswerCover(final Quanda quanda) throws Exception {
    if (quanda.getId() > 0 && quanda.getAnswerCover() != null
        && quanda.getAnswerCover().length > 0) {
      final String filePath = getAnswerCoverUrl(quanda);
      writeToStore(filePath, quanda.getAnswerCover());
      return filePath;
    }
    return null;
  }

  public String saveAnswerMedia(final Quanda quanda) throws Exception {
    if (quanda.getId() > 0 && quanda.getAnswerMedia() != null
        && quanda.getAnswerMedia().length > 0) {
      final String filePath = getAnswerUrl(quanda);
      writeToStore(filePath, quanda.getAnswerMedia());
      return filePath;
    }
    return null;
  }


  public byte[] readAvatarImage(final String avatarUrl) throws Exception {
    return readByUrl(avatarUrl);
  }

  private byte[] readByUrl(final String url) throws Exception {
    if (StringUtils.isBlank(url)) {
      return null;
    }
    return readFromStore(url);
  }

  public String saveAvatarImage(final Profile profile) throws Exception {
    if (!StringUtils.isBlank(profile.getUid())
        && profile.getAvatarImage() != null
        && profile.getAvatarImage().length > 0) {
      final String filePath = getAvatarUrl(profile);
      writeToStore(filePath, profile.getAvatarImage());
      return filePath;
    }

    return null;
  }

  private String getAvatarUrl(final Profile profile) {
    return String.format("%s/%s/%s/%s", PREFIX, USER_ROOT, profile.getUid(),
        "avatar");
  }

  private String getAnswerUrl(final Quanda quanda) {
    return String.format("%s/%s/%d", PREFIX, ANSWER_ROOT, quanda.getId());
  }

  private String getAnswerCoverUrl(final Quanda quanda) {
    return String.format("%s/%s/%d.cover", PREFIX, ANSWER_ROOT, quanda.getId());
  }

  String getObjectName(final String filePath) {
    final Path p = Paths.get(filePath);
    return filePath.substring(filePath.indexOf(p.getRoot().toString() + 1));
  }

  public byte[] readFromStore(final String filePath)
      throws Exception {
    final AmazonS3URI uri = new AmazonS3URI(filePath);
    final S3Object object = s3.getObject(new GetObjectRequest(
        uri.getBucket(), uri.getKey()));

    byte[] result = null;
    result = object == null ? null
        : ByteStreams.toByteArray(object.getObjectContent());
    return result;
  }

  public void writeToStore(final String filePath, final byte[] image) {
    final AmazonS3URI uri = new AmazonS3URI(filePath);
    final String bucketName = uri.getBucket();
    final String objectName = uri.getKey();

    if (!s3.doesBucketExist(bucketName)) {
      s3.createBucket(bucketName);
    }

    if (s3.doesObjectExist(bucketName, objectName)) {
      s3.deleteObject(bucketName, objectName);
    }

    final ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(image.length);

    s3.putObject(new PutObjectRequest(bucketName, objectName,
        new ByteArrayInputStream(image), metadata));
  }
}
