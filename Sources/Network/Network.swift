//
//  File.swift
//
//
//  Created by Ankit.Agrawal on 08/05/21.
//

import Foundation

public typealias NetworkCompletion<Model: Codable> = (NetworkResult<Model>) -> Void

public protocol Network {

    associatedtype ResponseModel: Codable

    func fetchData(
        for request: URLRequest,
        completion: @escaping NetworkCompletion<ResponseModel>
    )

    func fetchData(
        for url: URL,
        body: Data?,
        completion: @escaping NetworkCompletion<ResponseModel>
    )

    func fetchData(
        for urlString: String,
        body: Data?,
        completion: @escaping NetworkCompletion<ResponseModel>
    )
}
