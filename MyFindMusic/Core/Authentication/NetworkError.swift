//
//  NetworkError.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/29/23.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidServerResponse
    case generalError
}
