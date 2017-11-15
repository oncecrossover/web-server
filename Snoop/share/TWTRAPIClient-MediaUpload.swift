//
//  TWTRAPIClient-MediaUpload.swift
//  Snoop
//
//  Created by Bingo Zhou on 11/16/17.
//  Copyright © 2017 Vinsider, Inc. All rights reserved.
//

import Foundation
import TwitterKit

public enum TWTRMediaUploadStatus
{
  case Init(totalBytes:Int, mimeType:String);
  case Inited(mediaId:String);
  case Append(mediaId:String, totalSegmentCount:Int);
  case Appended(mediaId:String);
  case SegmentAppend(mediaId:String, segmentIndex:Int, remainingSegmentCount:Int);
  case SegmentAppended(mediaId:String, segmentIndex:Int);
  case Finalize(mediaId:String);
  case Finalized(mediaId:String);
  case Error(mediaId:String?, message:String);

  func toString() -> String
  {
    switch (self)
    {
    case .Init(let totalBytes, let mimeType) :
      return "TWTRMediaUploadStatus.Init(totalBytes:\(totalBytes), mimeType:\(mimeType))";

    case .Inited(let mediaId) :
      return "TWTRMediaUploadStatus.Inited(mediaId:\(mediaId))";

    case .Append(let mediaId, let totalSegmentCount) :
      return "TWTRMediaUploadStatus.Append(mediaId:\(mediaId), totalSegmentCount:\(totalSegmentCount))";

    case .Appended(let mediaId) :
      return "TWTRMediaUploadStatus.Appended(mediaId:\(mediaId))";

    case .SegmentAppend(let mediaId, let segmentIndex, let remainingSegmentCount) :
      return "TWTRMediaUploadStatus.SegmentAppend(mediaId:\(mediaId), segementIndex:\(segmentIndex), remainingSegmentCount:\(remainingSegmentCount))";

    case .SegmentAppended(let mediaId, let segmentIndex) :
      return "TWTRMediaUploadStatus.SegmentAppended(mediaId:\(mediaId), segmentIndex: \(segmentIndex))";

    case .Finalize(let mediaId) :
      return "TWTRMediaUploadStatus.Finalize(mediaId:\(mediaId))";

    case .Finalized(let mediaId) :
      return "TWTRMediaUploadStatus.Finalized(mediaId:\(mediaId))";

    case .Error(let mediaId, let message) :
      return "TWTRMediaUploadStatus.Error(mediaId:\(String(describing: mediaId)), message:\(message))";
    }
  }
}

public typealias TWTRStatusUpdateCallback = (_ tweetId: String?, _ error: Error?) -> Void;

public typealias TWTRMediaUploadCallback = (_ mediaId:String?, _ error: Error?) -> Void;

public typealias TWTRMediaUploadStatusCallback = (_ status:TWTRMediaUploadStatus) -> Void;

/**
 * Used to wrap closure to store in associated objects.
 */
private class ClosureWrapper : NSObject, NSCopying
{
  convenience init(closure: TWTRMediaUploadStatusCallback?)
  {
    self.init()
    self.closure = closure;
  }

  var closure:TWTRMediaUploadStatusCallback?;

  public func copy(with zone: NSZone? = nil) -> Any {
    let wrapper: ClosureWrapper = ClosureWrapper()
    wrapper.closure = self.closure;

    return wrapper
  }
}

extension TWTRAPIClient
{
  private struct AssociatedKeys
  {
    static var MediaUploadCallback:String = "MediaUploadCallback";
  }

  // MARK: Properties

  var mediaUploadStatusCallback: TWTRMediaUploadStatusCallback?
  {
    get
    {
      if let wrapper = objc_getAssociatedObject(self, &AssociatedKeys.MediaUploadCallback) as? ClosureWrapper
      {
        return wrapper.closure;
      }

      return nil;
    }
    set
    {
      objc_setAssociatedObject(self, &AssociatedKeys.MediaUploadCallback, ClosureWrapper(closure: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
    }
  }

  // MARK: Extension API
  func statusUpdate(status:String, mediaURL: URL, callback:@escaping TWTRStatusUpdateCallback) {
    self.statusUpdate(status: status, mediaURL: mediaURL, mimeType: nil, callback: callback)
  }

  func statusUpdate(status:String, mediaURL: URL, mimeType:String?, callback:@escaping TWTRStatusUpdateCallback)
  {
    if let data:NSData = NSData(contentsOf: mediaURL)
    {
      self.statusUpdate(status: status, mediaData: data, mimeType: mimeType, callback: callback);
    }
    else
    {
      callback(nil, NSError(domain: TWTRErrorDomain, code: TWTRErrorCode.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey : "Could not read media file"]));
    }
  }

  func statusUpdate(status:String, mediaData:NSData, mimeType:String?, callback:@escaping TWTRStatusUpdateCallback)
  {
    let resolvedMimeType = mimeType ?? discoverMimeTypeFromData(data: mediaData);

    self.mediaUploadChunked(data: mediaData, mimeType: resolvedMimeType) { (mediaId:String?, uploadError: Error?) -> () in

      if uploadError == nil
      {
        self.postStatus(status: status, mediaId: mediaId) {
          (mediaId:String?, postError: Error?) -> () in
          callback(mediaId, postError)
        }
      }
      else
      {
        callback(nil, uploadError);
      }
    };
  }

  func postStatus(status:String, mediaId:String?, callback:@escaping TWTRStatusUpdateCallback) {

    let STATUS_UPDATE_ENDPOINT:String = "https://api.twitter.com/1.1/statuses/update.json"

    let params =
      [
        "status" : status,
        "media_ids" : mediaId!
    ];

    var tweetError:NSError?;
    let request = self.urlRequest(withMethod: "POST", url: STATUS_UPDATE_ENDPOINT, parameters: params, error: &tweetError);

    if tweetError == nil
    {
      self.sendTwitterRequest(request) { (response:URLResponse?, responseData:Data?, responseError:Error?) -> () in

        if responseError == nil
        {
          do
          {
            let json:NSDictionary? = try JSONSerialization.jsonObject(with: responseData!, options: .mutableContainers) as? NSDictionary

            if let tweetId = json?["id_str"] as? String {
              callback(tweetId, nil)
            } else {
              callback(nil, NSError(domain: TWTRErrorDomain, code: TWTRErrorCode.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey : "Could not obtain unique tweet for media id \(String(describing: mediaId))"]));
            }
          }
          catch let parseError as NSError
          {
            callback(nil, parseError);
          }
          catch
          {
            callback(nil, NSError(domain: TWTRAPIErrorDomain, code: TWTRErrorCode.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey : "Error parsing received Tweet"]));
          }
        }
        else
        {
          callback(nil, responseError);
        }
      };
    }
    else
    {
      callback(nil, tweetError);
    }
  }

  func mediaUploadChunked(data:NSData, mimeType:String, callback:@escaping TWTRMediaUploadCallback)
  {
    let MEDIA_UPLOAD_ENDPOINT = "https://upload.twitter.com/1.1/media/upload.json";

    var chunks:[NSData] = self.separateMediaToChunks(data: data);

    func initUpload(callback:@escaping TWTRMediaUploadCallback)
    {
      self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Init(totalBytes: data.length, mimeType: mimeType));

      let params =
        [
          "command" : "INIT",
          "total_bytes" : NSNumber(value: data.length).stringValue,
          "media_type" : mimeType,
          "media_category": "tweet_video"
      ];

      var initError:NSError?;
      let request = self.urlRequest(withMethod: "POST", url: MEDIA_UPLOAD_ENDPOINT, parameters: params, error: &initError);

      if initError == nil
      {
        self.sendTwitterRequest(request) { (response:URLResponse?, responseData:Data?, responseError:Error?) -> () in

          if responseError == nil
          {
            do
            {
              let json:NSDictionary? = try JSONSerialization.jsonObject(with: responseData!, options: .mutableContainers) as? NSDictionary;

              if let mediaId = json?["media_id_string"] as? NSString
              {
                self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Inited(mediaId: mediaId as String));

                callback(mediaId as String, nil);
              }
              else
              {
                self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Error(mediaId: nil, message: "Could not obtain media_id_string from response"));

                callback(nil, NSError(domain: TWTRErrorDomain, code: TWTRErrorCode.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey : "Could not obtain media_id_string from response"]));
              }
            }
            catch let parseError as NSError
            {
              self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Error(mediaId: nil, message: parseError.localizedDescription));

              callback(nil, parseError);
            }
            catch
            {
              self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Error(mediaId: nil, message: "Error parsing received data"));

              callback(nil, NSError(domain: TWTRAPIErrorDomain, code: TWTRErrorCode.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey : "Error parsing received data"]));
            }
          }
          else
          {
            self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Error(mediaId: nil, message: responseError!.localizedDescription));

            callback(nil, responseError);
          }
        };
      }
      else
      {
        self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Error(mediaId: nil, message: initError!.localizedDescription));

        callback(nil, initError);
      }
    }

    func appendChunks(mediaId:String, segmentIndex:Int, callback:@escaping TWTRMediaUploadCallback)
    {
      self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Append(mediaId: mediaId, totalSegmentCount: chunks.count));

      if chunks.isEmpty
      {
        self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Appended(mediaId: mediaId));

        callback(mediaId, nil);
      }
      else
      {
        let chunk = chunks.removeFirst();

        self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.SegmentAppend(mediaId: mediaId, segmentIndex: segmentIndex, remainingSegmentCount: chunks.count));

        let params:[String : String] =
          [
            "command" : "APPEND",
            "media_id" : mediaId,
            "segment_index" : String(segmentIndex),
            "media" : chunk.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        ];

        var appendError:NSError?;
        let request = self.urlRequest(withMethod: "POST", url: MEDIA_UPLOAD_ENDPOINT, parameters: params, error: &appendError);

        if appendError == nil
        {
          self.sendTwitterRequest(request) { (response:URLResponse?, responseData:Data?, responseError:Error?) -> () in

            if responseError == nil
            {
              self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.SegmentAppended(mediaId: mediaId, segmentIndex: segmentIndex));

              appendChunks(mediaId: mediaId, segmentIndex: segmentIndex + 1, callback: callback);
            }
            else
            {
              self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Error(mediaId: nil, message: responseError!.localizedDescription));

              callback(nil, responseError);
            }
          };
        }
        else
        {
          self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Error(mediaId: nil, message: appendError!.localizedDescription));

          callback(nil, appendError);
        }
      }
    }

    func finalizeUpload(mediaId:String, callback:@escaping TWTRMediaUploadCallback)
    {
      self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Finalize(mediaId: mediaId));

      let params =
        [
          "command" : "FINALIZE",
          "media_id" : mediaId
      ];

      var finalizeError:NSError?;
      let request = self.urlRequest(withMethod: "POST", url: MEDIA_UPLOAD_ENDPOINT, parameters: params, error: &finalizeError);

      if finalizeError == nil
      {
        self.sendTwitterRequest(request) { (response:URLResponse?, responseData:Data?, responseError:Error?) -> () in

          if responseError == nil
          {
            self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Finalized(mediaId: mediaId));

            callback(mediaId, nil);
          }
          else
          {
            self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Error(mediaId: nil, message: responseError!.localizedDescription));

            callback(nil, responseError);
          }
        }
      }
      else
      {
        self.mediaUploadStatusCallback?(TWTRMediaUploadStatus.Error(mediaId: nil, message: finalizeError!.localizedDescription));

        callback(nil, finalizeError);
      }
    }

    func checkStatus(mediaId:String, callback:@escaping (_ ready:Bool, _ error: Error?) -> ())
    {
      let params =
        [
          "command" : "STATUS",
          "media_id" : mediaId
      ];

      var statusError:NSError?;
      let request = self.urlRequest(withMethod: "GET", url: MEDIA_UPLOAD_ENDPOINT, parameters: params, error: &statusError);

      if statusError == nil
      {
        self.sendTwitterRequest(request) { (response:URLResponse?, responseData:Data?, responseError:Error?) -> () in

          if responseError == nil
          {
            do
            {
              /**
               We must wait for some seconds before the media is processed successfully by Twitter.
               Twitter media state transition flow is: pending -> in_progress -> [failed|succeeded]
               */
              let json: NSDictionary? = try JSONSerialization.jsonObject(with: responseData!, options: .mutableContainers) as? NSDictionary
              let processingInfo: NSDictionary? = json?["processing_info"]  as? NSDictionary
              let state = processingInfo?["state"] as! String

              if (state == "failed") {
                callback(false, NSError(domain: TWTRErrorDomain, code: TWTRErrorCode.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey : "Failed to process media with id \(String(describing: mediaId))"]));
              } else if (state == "succeeded") {
                callback(true, nil)
              } else if (state == "pending" || state == "in_progress") {
                let check_after_secs = processingInfo?["check_after_secs"] as! Int
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(check_after_secs)) {
                   checkStatus(mediaId: mediaId, callback: callback)
                }
              }
            }
            catch let parseError as NSError
            {
              callback(false, parseError);
            }
            catch
            {
              callback(false, NSError(domain: TWTRAPIErrorDomain, code: TWTRErrorCode.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey : "Can't parse received data."]));
            }
          }
          else
          {
            callback(false, responseError);
          }
        };
      }
      else
      {
        callback(false, statusError);
      }
    }

    initUpload() { (mediaId:String?, initError: Error?) -> () in

      if initError == nil
      {
        appendChunks(mediaId: mediaId!, segmentIndex: 0) { (mediaId:String?, appendError: Error?) -> () in

          if appendError == nil
          {
            finalizeUpload(mediaId: mediaId!) { (mediaId:String?, finalizeError: Error?) -> () in

              if finalizeError == nil
              {
                checkStatus(mediaId: mediaId!) { (ready: Bool, statusError: Error?) -> () in
                  if statusError == nil
                  {
                    if ready
                    {
                      callback(mediaId, nil);
                    }
                    else
                    {
                      callback(nil, NSError(domain: TWTRErrorDomain, code: TWTRErrorCode.unknown.rawValue, userInfo: nil));
                    }
                  }
                  else
                  {
                    callback(nil, statusError);
                  }
                };
              }
              else
              {
                callback(nil, finalizeError);
              }
            };
          }
          else
          {
            callback(nil, appendError);
          }
        };
      }
      else
      {
        callback(nil, initError);
      }
    }
  }

  // MARK: Support functions

  func separateMediaToChunks(data:NSData) -> [NSData]
  {
    let MAX_CHUNK_SIZE:Int = 1000 * 1000 * 2; // 2Mb

    var chunks:[NSData] = [];

    let totalLenght:Float = Float(data.length);
    let chunkLength:Float = Float(MAX_CHUNK_SIZE);

    if totalLenght <= chunkLength
    {
      chunks.append(data);
    }
    else
    {
      let count = Int(ceil(totalLenght / chunkLength) - 1);

      for i in 0...count
      {
        var range:NSRange!;

        if i == count
        {
          range = NSMakeRange(i * Int(chunkLength), Int(totalLenght) - i * Int(chunkLength));
        }
        else
        {
          range = NSMakeRange(i * Int(chunkLength), Int(chunkLength));
        }

        let chunk = data.subdata(with: range);

        chunks.append(chunk as NSData);
      }
    }

    return chunks;
  }

  /// Returns mime-type according to data's heading bytes
  /// Discover based on: http://www.garykessler.net/library/file_sigs.html
  func discoverMimeTypeFromData(data:NSData) -> String
  {
    let bmp:[UInt8] = [0x42, 0x4D];
    let jpg:[UInt8] = [0xFF, 0xD8, 0xFF];
    let png:[UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    let mp4:[UInt8] = [0x66, 0x74, 0x79, 0x70];
    let gif:[UInt8] = [0x47, 0x49, 0x46, 0x38];
    let webp:[UInt8] = [0x52, 0x49, 0x46, 0x46];

    var headChars:[UInt8] = [UInt8](repeating: 0, count: 8);
    data.getBytes(&headChars, length: 8);

    if memcmp(bmp, headChars, 2) == 0
    {
      return "image/bmp";
    }
    else if memcmp(jpg, headChars, 3) == 0
    {
      return "image/jpeg";
    }
    else if memcmp(png, headChars, 8) == 0
    {
      return "image/png";
    }
    else if memcmp(gif, headChars, 4) == 0
    {
      return "image/gif";
    }
    else if memcmp(webp, headChars, 4) == 0
    {
      return "image/webp";
    }
    else if memcmp(mp4, [UInt8](headChars[4..<headChars.count]), 4) == 0 // ignoring first 4 byte offset
    {
      return "video/mp4";
    }
    else
    {
      return "application/octet-stream";
    }
  }
}

