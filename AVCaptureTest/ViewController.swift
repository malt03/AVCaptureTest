//
//  ViewController.swift
//  AVCaptureTest
//
//  Created by Koji Murata on 2016/03/24.
//  Copyright © 2016年 Koji Murata. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
  private var session: AVCaptureSession!
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: [AVAudioSessionCategoryOptions.MixWithOthers, AVAudioSessionCategoryOptions.DefaultToSpeaker])
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("error")
    }
    
    session = AVCaptureSession()
    
    session.beginConfiguration()
    
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    let deviceInput = try! AVCaptureDeviceInput(device: device)
    
    let dataOutput = AVCaptureVideoDataOutput()
    dataOutput.videoSettings = [
      kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA)
    ]
    dataOutput.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
    
    session.addInput(deviceInput)
    session.addOutput(dataOutput)
    session.sessionPreset = AVCaptureSessionPresetHigh
    
    let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
    let audioInput = try! AVCaptureDeviceInput(device: audioDevice)
    
    session.addInput(audioInput)
    
    let audioOutput = AVCaptureAudioDataOutput()
    session.addOutput(audioOutput)

    var videoConnection: AVCaptureConnection? = nil
    for connection in dataOutput.connections as! [AVCaptureConnection] {
      for port in connection.inputPorts as! [AVCaptureInputPort] {
        if port.mediaType == AVMediaTypeVideo {
          videoConnection = connection
        }
      }
    }
    if videoConnection!.supportsVideoOrientation {
      videoConnection?.videoOrientation = .Portrait
    }
    
    session.commitConfiguration()
    session.startRunning()
    
  }

  func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
    print(AVAudioSession.sharedInstance().categoryOptions, AVAudioSession.sharedInstance().category)
    let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
    let ciImage = CIImage(CVPixelBuffer: pixelBuffer)
    (view as! UIImageView).image = UIImage(CIImage: ciImage)
  }
}

