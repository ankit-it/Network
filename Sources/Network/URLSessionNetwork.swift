//
//  File.swift
//  
//
//  Created by Ankit.Agrawal on 08/05/21.
//

import Foundation

public class URLSessionNetwork<Model: Codable>: Network {
    public typealias ResponseModel = Model

    public let session: URLSession

    public init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }

    public func fetchData(
        for request: URLRequest,
        completion: @escaping NetworkCompletion<Model>
    ) {
        session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                let networkError = BaseNetworkError.error(
                    response: response,
                    error: error
                )
                completion(NetworkResult.failure(networkError))
                return
            }

            // Decode data
            do {
                let responseModel = try JSONDecoder().decode(
                    ResponseModel.self,
                    from: data
                )
                completion(NetworkResult.success(responseModel))
            } catch {
                let networkError = BaseNetworkError.decodingError(
                    response: response,
                    error: error
                )
                completion(NetworkResult.failure(networkError))
            }
        }.resume()
    }

    public func fetchData(
        for urlString: String,
        body: Data?,
        completion: @escaping NetworkCompletion<Model>
    ) {
        guard let url = URL(string: urlString) else {
            completion(NetworkResult.failure(BaseNetworkError.invalidURLError()))
            return
        }

        fetchData(for: url, body: body, completion: completion)
    }

    public func fetchData(
        for url: URL,
        body: Data?,
        completion: @escaping NetworkCompletion<Model>
    ) {
        var request = URLRequest(url: url)
        if let bodyData = body {
            request.httpMethod = "POST"
            request.httpBody = bodyData
        } else {
            request.httpMethod = "GET"
        }

        request.addValue("application/json", forHTTPHeaderField: "accept")
        fetchData(for: request, completion: completion)
    }
}
