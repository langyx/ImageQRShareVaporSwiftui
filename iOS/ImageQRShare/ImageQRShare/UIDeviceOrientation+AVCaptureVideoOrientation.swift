//
//  UIDeviceOrientation.swift
//  ImageQRShare
//
//  Created by Yannis LANG on 27/06/2022.
//

import Foundation
import UIKit
import AVFoundation

extension UIDeviceOrientation {
    var asCaptureVideoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        case .portraitUpsideDown: return .portraitUpsideDown
        default: return .portrait
        }
    }
}
