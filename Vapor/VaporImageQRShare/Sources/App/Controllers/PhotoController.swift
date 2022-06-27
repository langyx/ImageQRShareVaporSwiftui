//
//  PhotoController.swift
//  
//
//  Created by Yannis LANG on 23/06/2022.
//

import Vapor
import Foundation

struct PhotoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let photos = routes.grouped("photos")
        photos.post(use: create)
        photos.delete(":file", use: delete)
    }
    
    func create(req: Request) async throws -> String  {
        guard let data = req.body.data else {
            throw(Abort(.noContent))
        }
        
        guard case MimeType.image(let imageType) = MimeType(data: Data(buffer: data)) else {
            throw(Abort(.unsupportedMediaType))
        }
        
        let photoId = UUID()
        let fileName = photoId.uuidString + ".\(imageType)"
        let path = req.application.directory.publicDirectory + "photos/" + fileName
        
        let handle = try await req.application.fileio.openFile(path: path, mode: .write, flags: .allowFileCreation(posixMode:0x744), eventLoop: req.eventLoop).get()
        
        req.application.fileio.write(fileHandle: handle, buffer: data, eventLoop: req.eventLoop).whenSuccess{
            try? handle.close()
        }
        return fileName
    }
    
    func delete(req: Request) throws -> String {
        guard let file = req.parameters.get("file") else {
            throw Abort(.notFound)
        }
        let path = req.application.directory.publicDirectory + "photos/" + file
        try FileManager.default.removeItem(atPath: path)
        return path
    }
}
