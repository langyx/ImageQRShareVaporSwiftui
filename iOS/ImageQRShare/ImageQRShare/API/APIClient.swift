//
//  ApiClient.swift
//  ImageQRShare
//
//  Created by Yannis LANG on 24/06/2022.
//

import Foundation

enum ClientError: Error {
    case badURL
}

struct APIClient {
    let root = "http://192.168.1.63:8080/photos"
    private var session = URLSession.shared

    func upload(_ data: Data) async throws -> (Data, URLResponse) {
        guard let url = URL(string: root) else {
            throw(ClientError.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return try await session.upload(for: request, from: data)
    }
}
