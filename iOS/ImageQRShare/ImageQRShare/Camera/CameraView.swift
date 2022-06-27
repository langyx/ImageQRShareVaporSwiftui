//
//  CameraView.swift
//  ImageQRShare
//
//  Created by Yannis LANG on 24/06/2022.
//

import UIKit
import SwiftUI
import AVFoundation


struct CameraView: View {
    @ObservedObject var cameraViewViewModel = CameraViewViewModel()
    var body: some View {
        ZStack {
            if let _ = cameraViewViewModel.image {
                imagePreview
            }else{
                cameraView
            }
            if let qr = cameraViewViewModel.qr {
                Image(uiImage: qr)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .onTapGesture {
                        cameraViewViewModel.qr = nil
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 5)
                    )
                    .padding()
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

extension CameraView {
    var cameraView: some View {
        CaptureVideoPreview(captureSession: cameraViewViewModel.captureSession)
                .task {
                    await cameraViewViewModel.requestAccess()
                }
                .overlay {
                    VStack{
                        Spacer()
                        Button("TakePic", action: cameraViewViewModel.takePhoto)
                            .buttonStyle(.bordered)
                            .disabled(cameraViewViewModel.working)
                    }
                    .padding()
                }
    }
    
    var imagePreview: some View {
        Group {
            if let image = cameraViewViewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        VStack{
                            Spacer()
                            Button("SharePic", action: {
                                Task {
                                    await cameraViewViewModel.sharePic()
                                }
                            })
                            .buttonStyle(.bordered)
                            .disabled(cameraViewViewModel.working)
                        }
                        .padding()
                    }
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
