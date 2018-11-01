package com.wallchain.server.util;

import java.io.ByteArrayInputStream;

import org.apache.commons.lang3.StringUtils;
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
import com.amazonaws.services.s3.model.AccessControlList;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.GroupGrantee;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.Permission;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.google.common.annotations.VisibleForTesting;
import com.google.common.io.ByteStreams;
import com.wallchain.server.db.model.Profile;
import com.wallchain.server.db.model.Quanda;
import com.wallchain.server.web.HttpSnoopServer;

/**
 * There are two kinds of URLs, S3 and Cloudfront. Backends writes data to S3
 * based on S3 URLs, but frontends stream data from Cloudfront based on
 * Cloudfront URLs. DB will only store Cloudfront URLs being returned to
 * frontends as a result of query.
 */
public class ObjectStoreClient {
  protected static final Logger LOG = LoggerFactory
      .getLogger(ObjectStoreClient.class);

  private static String CLOUDFRONT_URI_PREFIX = "https://ddk9xa5p5b3lb.cloudfront.net";
  private static String s3UriPrefix;

  private static final String HOME_ROOT = "com.snoop.home";
  private static String home_users_prefix;

  private static final String QUANDA_ROOT = "com.snoop.quanda";
  private static String quanda_answers_thumbnails_prefix;
  private static String quanda_answers_videos_prefix;

  private static AmazonS3 s3 = null;

  @VisibleForTesting
  static void setS3UriPrefix(final String prefix) {
    s3UriPrefix = prefix;
  }

  static {
    /* init S3 root directory */
    if (HttpSnoopServer.LIVE) {
      s3UriPrefix = "https://s3-us-west-2.amazonaws.com";
      home_users_prefix = "users";
      quanda_answers_thumbnails_prefix = "answers/thumbnails";
      quanda_answers_videos_prefix = "answers/videos";
    } else {
      s3UriPrefix = "https://s3-us-west-2.amazonaws.com/com.snoop.deployment.test";
      home_users_prefix = "test/users";
      quanda_answers_thumbnails_prefix = "test/answers/thumbnails";
      quanda_answers_videos_prefix = "test/answers/videos";
    }

    /* init S3 client */
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

  public String saveAnswerCover(final Quanda quanda) throws Exception {
    if (quanda.getId() > 0 && quanda.getAnswerCover() != null
        && quanda.getAnswerCover().length > 0) {
      final String filePath = getAnswerThumbnailS3Url(quanda);
      writeToStore(filePath, quanda.getAnswerCover());
      return getAnswerThumbnailCloudfrontUrl(quanda);
    }
    return null;
  }

  public String saveAnswerMedia(final Quanda quanda) throws Exception {
    if (quanda.getId() > 0 && quanda.getAnswerMedia() != null
        && quanda.getAnswerMedia().length > 0) {
      final String filePath = getAnswerVideoS3Url(quanda);
      writeToStore(filePath, quanda.getAnswerMedia());
      return getAnswerVideoCloudfrontUrl(quanda);
    }
    return null;
  }

  public String saveAvatarImage(final Profile profile) throws Exception {
    if (profile.getId() != null
        && profile.getAvatarImage() != null
        && profile.getAvatarImage().length > 0) {
      final String s3url = getAvatarS3Url(profile);
      writeToStore(s3url, profile.getAvatarImage());
      return getAvatarCloudfrontUrl(profile);
    }

    return null;
  }

  @VisibleForTesting
  String getAvatarS3Url(final Profile profile) {
    /*
     * e.g.
     * https://s3-us-west-2.amazonaws.com/com.snoop.home/users/xxx@gmail.com/1/
     * 1.avatar.jpg
     */
    return String.format("%s/%s/%s/%d/%d.avatar.jpg", s3UriPrefix, HOME_ROOT,
        home_users_prefix, profile.getId(), profile.getId());
  }

  private String getAvatarCloudfrontUrl(final Profile profile) {
    /*
     * e.g.
     * https://ddk9xa5p5b3lb.cloudfront.net/users/xxx@gmail.com/1/1.avatar.jpg
     */
    return String.format("%s/%s/%d/%d.avatar.jpg", CLOUDFRONT_URI_PREFIX,
        home_users_prefix, profile.getId(), profile.getId());
  }

  private String getAnswerThumbnailS3Url(final Quanda quanda) {
    /*
     * e.g.
     * https://s3-us-west-2.amazonaws.com/com.snoop.quanda/answers/thumbnails/1/
     * 1.thumbnail.jpg
     */
    return String.format("%s/%s/%s/%d/%d.thumbnail.jpg", s3UriPrefix,
        QUANDA_ROOT, quanda_answers_thumbnails_prefix, quanda.getId(),
        quanda.getId());
  }

  private String getAnswerThumbnailCloudfrontUrl(final Quanda quanda) {
    /*
     * e.g.
     * https://ddk9xa5p5b3lb.cloudfront.net/answers/thumbnails/1/1.thumbnail.jpg
     */
    return String.format("%s/%s/%d/%d.thumbnail.jpg", CLOUDFRONT_URI_PREFIX,
        quanda_answers_thumbnails_prefix, quanda.getId(), quanda.getId());
  }

  @VisibleForTesting
  String getAnswerVideoS3Url(final Quanda quanda) {
    /*
     * e.g.
     * https://s3-us-west-2.amazonaws.com/com.snoop.quanda/answers/videos/1/1.
     * video.mp4
     */
    return String.format("%s/%s/%s/%d/%d.video.mp4", s3UriPrefix, QUANDA_ROOT,
        quanda_answers_videos_prefix, quanda.getId(), quanda.getId());
  }

  private String getAnswerVideoCloudfrontUrl(final Quanda quanda) {
    /*
     * e.g. https://ddk9xa5p5b3lb.cloudfront.net/answers/videos/1/1.video.mp4
     */
    return String.format("%s/%s/%d/%d.video.mp4", CLOUDFRONT_URI_PREFIX,
        quanda_answers_videos_prefix, quanda.getId(), quanda.getId());
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

    /* grant all users (Everyone) read access, i.e. open/download */
    AccessControlList acl = new AccessControlList();
    acl.grantPermission(GroupGrantee.AllUsers, Permission.Read);

    s3.putObject(new PutObjectRequest(bucketName, objectName,
        new ByteArrayInputStream(image), metadata).withAccessControlList(acl));
  }
}
