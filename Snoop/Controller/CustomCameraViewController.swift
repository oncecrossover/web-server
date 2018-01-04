//
//  CustomCameraCustomCameraViewController.swift
//  Snoop
//
//  Created by Bingo Zhou on 12/5/17.
//  Copyright © 2017 Vinsider, Inc. All rights reserved.
//

import Foundation
import GPUImage
import AVKit

let CustomCameraViewControllerMediaURL: String = "CustomCameraViewControllerMediaURL"

protocol CustomCameraViewControllerDelegate {
  func didFinishPickingMedia(_ camera: CustomCameraViewController, withInfo info: [String : Any])
}

class CustomCameraViewController: UIViewController {
  /* set by caller */
  var delegate: CustomCameraViewControllerDelegate?
  var cameraOverlayView: GPUImageView?
  var cameraPosition: AVCaptureDevice.Position = .front
  var sessionPreset: AVCaptureSession.Preset = .high

  /* internal vars/constants */
  private var camera : GPUImageVideoCamera?
  private var filterGroup: GPUImageFilterGroup?
  private var movieWriter : GPUImageMovieWriter?

  private var fileURL : URL {
    return URL(fileURLWithPath: "\(NSTemporaryDirectory())filtered_video.mov")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    /* set render view */
    view.insertSubview(cameraOverlayView!, at: 0)

    /* start capture */
    startVideoCapture()
  }
}

// capture / record video
extension CustomCameraViewController {
  private func startVideoCapture() {
    /* init filters */
    filterGroup = filterGroup ?? self.createFilterGroup(withRenderView: cameraOverlayView)

    /* init camera */
    camera = camera ?? self.createCamera(withFilterGroup: filterGroup)

    /* init writer */
    movieWriter = movieWriter ?? self.createMovieWriter(forCamera: camera, forFilterGroup: filterGroup)

    /* capture video */
    camera?.startCapture()

    /* reduce black flash between two consecutive video segments */
    camera?.pauseCapture()
    camera?.resumeCameraCapture()
  }

  func startRecording() {

    startVideoCapture()

    movieWriter?.startRecording()
  }

  func stopVideoCapture() {
    /* clean camera */
    camera?.pauseCapture()
    camera?.stopCapture()
    camera?.removeAllTargets()
    camera = nil

    /* clean fitlers */
    filterGroup?.removeAllTargets()
    filterGroup = nil
  }

  func stopRecording() {
    /* clean writer */
    movieWriter?.finishRecording()
    movieWriter = nil

    // stop capture
    stopVideoCapture()

    /* call to save recorded video */
    self.delegate?.didFinishPickingMedia(self, withInfo: [CustomCameraViewControllerMediaURL : self.fileURL])

    // start capture
    startVideoCapture()
  }
}

// camera operations
extension CustomCameraViewController {
  func rotateCamera() {
    self.camera?.rotateCamera()
    /* remember the most recent position */
    self.cameraPosition = self.camera?.cameraPosition() ?? .front
  }
}

// private functions
extension CustomCameraViewController {
  private func createMovieWriter(forCamera : GPUImageVideoCamera?,
                         forFilterGroup: GPUImageFilterGroup?) -> GPUImageMovieWriter? {
    do {
      try FileManager.default.removeItem(at: self.fileURL)
    } catch {
      print(error)
    }

    let movieWriter = GPUImageMovieWriter(movieURL: self.fileURL, size: self.view.bounds.size)
    movieWriter?.encodingLiveVideo = true

    /* set camera */
    forCamera?.audioEncodingTarget = movieWriter

    /* set filters */
    forFilterGroup?.addTarget(movieWriter)

    return movieWriter
  }

  private func createFilterGroup(withRenderView: GPUImageView?) -> GPUImageFilterGroup {
    let bilateralFilter = GPUImageBilateralFilter()
    let exposureFilter = GPUImageExposureFilter()
    let brightnessFilter = GPUImageBrightnessFilter()
    let satureationFilter = GPUImageSaturationFilter()

    bilateralFilter.addTarget(brightnessFilter)
    brightnessFilter.addTarget(exposureFilter)
    exposureFilter.addTarget(satureationFilter)

    let filterGroup = GPUImageFilterGroup()
    filterGroup.initialFilters = [bilateralFilter]
    filterGroup.terminalFilter = satureationFilter

    /* set render view */
    filterGroup.removeAllTargets()
    filterGroup.addTarget(withRenderView)

    return filterGroup
  }

  private func createCamera(withFilterGroup: GPUImageFilterGroup?) -> GPUImageVideoCamera? {
    let camera = GPUImageVideoCamera(sessionPreset: sessionPreset.rawValue, cameraPosition: cameraPosition)
    camera?.delegate = self
    camera?.outputImageOrientation = .portrait
    camera?.horizontallyMirrorFrontFacingCamera = true

    /* set filters */
    camera?.removeAllTargets()
    camera?.addTarget(withFilterGroup)
    return camera
  }
}

// GPUImageVideoCamera Delegate
extension CustomCameraViewController : GPUImageVideoCameraDelegate {
  func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
  }
}
