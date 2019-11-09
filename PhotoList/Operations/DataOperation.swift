//
//  DataOperation.swift
//  PhotoList
//
//  Created by Mariam on 9/11/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import Foundation

class DataOperation {
    
    var urlString = ""
    private var successHandler: (Any) -> Void
    private var failureHandler: (Error?) -> Void
    
    init(successHandler success: @escaping (Any) -> Void, failureHandler failure: @escaping (Error?) -> Void) {
        successHandler = success
        failureHandler = failure
    }
    
    func loadData() {
        guard let url = URL(string: urlString) else {
            handleError(nil)
            return
        }
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { receivedData, response, receivedError in
            if let error = receivedError {
                self.handleError(error)
                return
            }
            if let data = receivedData {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    self.handleData(json)
                } else {
                    self.handleData(data)
                }
            } else {
                self.handleError(nil)
            }
        })
        dataTask.resume()
    }
    
    func handleData(_ data: Any) {
        DispatchQueue.main.async {
            self.successHandler(data)
        }
    }
    
    func handleError(_ error: Error?) {
        DispatchQueue.main.async {
            self.failureHandler(error)
        }
    }
}
