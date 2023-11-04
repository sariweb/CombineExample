//
//  APICaller.swift
//  CombineExample
//
//  Created by Sergei on 04.11.2023.
//

import Combine
import Foundation

class APICaller {
    static let shared = APICaller()
    
    func fetchCompanies() -> Future<[String], Error> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                promise(.success(["Apple", "Google", "Microsoft", "Yandex"]))
            }
        }
    }
}
