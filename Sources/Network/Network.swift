import Foundation

public enum ErrorType: Int {
    case unknown
    case decoding
    case invalidURL

    var error: Error {
        return NSError(
            domain: "com.network.error",
            code: self.rawValue,
            userInfo: nil
        )
    }
}

public protocol Network {

    associatedtype ResponseModel: Codable

    func fetchData(
        for request: URLRequest,
        completion: @escaping (Result<ResponseModel, Error>) -> Void
    )

    func fetchData(
        for url: URL,
        body: Data?,
        completion: @escaping (Result<ResponseModel, Error>) -> Void
    )

    func fetchData(
        for urlString: String,
        body: Data?,
        completion: @escaping (Result<ResponseModel, Error>) -> Void
    )
}

public extension Network {
    func fetchData(
        for request: URLRequest,
        completion: @escaping (Result<ResponseModel, Error>) -> Void
    ) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                let resultantError: Error
                if let error = error {
                    resultantError = error
                } else if let response = response as? HTTPURLResponse {
                    resultantError = NSError(
                        domain: "",
                        code: response.statusCode,
                        userInfo: nil
                    )
                } else {
                    resultantError = ErrorType.unknown.error
                }
                completion(Result.failure(resultantError))
                return
            }

            // Decode data
            do {
                let responseModel = try JSONDecoder().decode(
                    ResponseModel.self,
                    from: data
                )
                completion(Result.success(responseModel))
            } catch {
                completion(Result.failure(error))
            }
        }.resume()
    }

    func fetchData(
        for urlString: String,
        body: Data?,
        completion: @escaping (Result<ResponseModel, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(Result.failure(ErrorType.invalidURL.error))
            return
        }

        fetchData(for: url, body: body, completion: completion)
    }

    func fetchData(
        for url: URL,
        body: Data?,
        completion: @escaping (Result<ResponseModel, Error>) -> Void
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

