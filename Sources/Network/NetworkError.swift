//
//  File.swift
//  
//
//  Created by Ankit.Agrawal on 08/05/21.
//

import Foundation

public protocol NetworkError {
    var statusCode: ErrorType { get }
    var response: URLResponse? { get }
    var error: Error? { get }
}

/// A value that represents either a success or a failure, including an
/// associated value in each case.
@frozen public enum NetworkResult<Success> where Success: Codable {
    /// A success, storing a `Success` value.
    case success(Success)

    /// A failure, storing a `Failure` value.
    case failure(NetworkError)
}

@frozen public enum ErrorType {
    case unknown
    case decoding
    case invalidURL
    case httpStatusCode(Int)
}

struct BaseNetworkError: NetworkError {
    let statusCode: ErrorType
    let response: URLResponse?
    let error: Error?

    private init(statusCode: ErrorType, response: URLResponse?, error: Error?) {
        self.statusCode = statusCode
        self.response = response
        self.error = error
    }

    static func unknownError(error: Error? = nil) -> NetworkError {
        return BaseNetworkError(
            statusCode: ErrorType.unknown,
            response: nil,
            error: error
        )
    }

    static func invalidURLError(error: Error? = nil) -> NetworkError {
        return BaseNetworkError(
            statusCode: ErrorType.invalidURL,
            response: nil,
            error: error
        )
    }

    static func decodingError(
        response: URLResponse?,
        error: Error
    ) -> NetworkError {
        return BaseNetworkError(
            statusCode: ErrorType.decoding,
            response: response,
            error: error
        )
    }

    static func error(response: URLResponse?, error: Error?) -> NetworkError {
        guard let httpResponse = response as? HTTPURLResponse else {
            return unknownError(error: error)
        }
        return BaseNetworkError(
            statusCode: ErrorType.httpStatusCode(httpResponse.statusCode),
            response: response,
            error: error
        )
    }
}
