//
//  CameraViewViewModel.swift
//  ImageQRShare
//
//  Created by Yannis LANG on 27/06/2022.
//

import Foundation
import AVFoundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class CameraViewViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var working = false
    
    private let photoOutput = AVCapturePhotoOutput()
    let captureSession = AVCaptureSession()
    
    private let apiClient = APIClient()
    
    @Published var image: UIImage?
    @Published var qr: UIImage?
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
}

extension CameraViewViewModel {
    func requestAccess() async  {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCapture()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted { startCapture() }
        default:
            print("noRights")
        }
    }
    
    func startCapture() {
        
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            captureSession.startRunning()
        }
    }
    
    func stopCapture() {
        captureSession.stopRunning()
    }
}

extension CameraViewViewModel {
    func takePhoto() {
        qr = nil
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            working = true
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        working = false
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        self.image = previewImage
    }
}

extension CameraViewViewModel {
    func sharePic() async {
        guard let data = image?.jpegData(compressionQuality: 1) else {
            return
        }
        working = true
        guard let (data, _) = try? await apiClient.upload(data),
              let fileName = String(data: data, encoding: .utf8) else {
            return
        }
        await MainActor.run {
            qr = generateQRCode(from: "\(apiClient.root)/\(fileName)")
            image = nil
            working = false
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
