//
//  CaptureVideoPreview.swift
//  ImageQRShare
//
//  Created by Yannis LANG on 27/06/2022.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation

struct CaptureVideoPreview: UIViewRepresentable {
    var captureSession: AVCaptureSession
    
    func makeUIView(context: Context) -> CaptureVideoPreviewView {
        let view = CaptureVideoPreviewView()
        view.previewLayer.session = captureSession
        view.previewLayer.videoGravity = .resizeAspectFill
        view.previewLayer.connection?.videoOrientation = UIDevice.current.orientation.asCaptureVideoOrientation
        return view
    }
    
    func updateUIView(_ uiView: CaptureVideoPreviewView, context: Context) {
        uiView.previewLayer.connection?.videoOrientation = UIDevice.current.orientation.asCaptureVideoOrientation
        for layer in uiView.layer.sublayers ?? [] {
            layer.frame = uiView.bounds
        }
    }
    
    class CaptureVideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
