//
//  NetworkManager.swift
//  UserProfile
//
//  Created by Jake Swedenburg on 12/5/18.
//  Copyright © 2018 Jake Swedenburg. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case Get = "GET"
    case Put = "PUT"
    case Post = "POST"
    case Patch = "PATCH"
    case Delete = "DELETE"
}

enum Result<T> {
    case Success(T)
    case Error(String)
}

class NetworkManager {
    
    private let baseURL = "https://q1o3gh76yb.execute-api.us-west-2.amazonaws.com/InterviewProd"
    func getUsersUrl() -> String {
        return baseURL + "/users"
    }
    
    func getUserUrl(id: String) -> String {
        return baseURL + "/users/\(id)"
    }
    
    func dataRequestForUrl(url: String, httpMethod: HTTPMethod, body: Data? = nil, completion: @escaping (_ result: Result<Data>) -> Void) {
        guard let requestUrl = URL(string: url) else { return completion(.Error("Bad url string")) }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        request.addValue("TqzKu0n0kW7uI5GkghsK76jMxLa4Km0EadtnmSM7", forHTTPHeaderField: "X-api-key")
        
        URLSession(configuration: .default).dataTask(with: request) { (data, response, error) in
            guard error == nil else { return completion(.Error(error!.localizedDescription))}
            
            guard let data = data else { return completion(.Error("No data")) }
            
            completion(.Success(data))
            }.resume()
        
    }
}
