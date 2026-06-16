//
//  NetworkService.swift
//  TDDFakeMockStubLab
//
//  Created by Tyson Pitcher on 6/8/26.
//

import Foundation

protocol ZomboNetwork {
    func fetchData(completion: (Data?) -> Void)
}

class DataFetcher {
    let networkService: ZomboNetwork
    
    init(networkService: ZomboNetwork) {
        self.networkService = networkService
    }
    
    func fetchData(completion: @escaping (Data?) -> Void) {
            networkService.fetchData { data in
                completion(data)
            
        }
    }
}

class MockNetworkService: ZomboNetwork {
    var zomboMusicIsLoaded: Bool = false
    
    func fetchData(completion: (Data?) -> Void) {
        zomboMusicIsLoaded = true
    }
}

class FakeNetworkService: ZomboNetwork {
    func fetchData(completion: (Data?) -> Void) {
        completion(nil)
    }
}

class StubNetworkService: ZomboNetwork {
    func fetchData(completion: (Data?) -> Void) {
        let data = Data()
        completion(data)
    }
}
