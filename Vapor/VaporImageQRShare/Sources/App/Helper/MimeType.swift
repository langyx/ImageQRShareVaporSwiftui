//
//  File.swift
//  
//
//  Created by Yannis LANG on 24/06/2022.
//

import Vapor
import Foundation

enum MimeType {
    case image(String), application(String), text(String)
    
    init(data: Data) {
        var b: UInt8 = 0
        data.copyBytes(to: &b, count: 1)
        
        switch b {
        case 0xFF:
            self = .image("jpg")
        case 0x89:
            self = .image("png")
        case 0x47:
            self = .image("gif")
        case 0x4D, 0x49:
            self = .image("tiff")
        case 0x25:
            self = .application("pdf")
        case 0xD0:
            self = .text("vnd")
        case 0x46:
            self = .text("plain")
        default:
            self = .application("octet-stream")
        }
    }
}
