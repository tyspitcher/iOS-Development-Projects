//
//  TDDFakeMockStubLabTests.swift
//  TDDFakeMockStubLabTests
//
//  Created by Tyson Pitcher on 6/8/26.
//
import Foundation
import Testing

@testable import TDDFakeMockStubLab

@MainActor
struct TDDFakeMockStubLabTests {
    let networkService = MockNetworkService()
    
    @Test ("Test fetching data from mock zombo.com network with successful network call and returns zombo music") func testFetchData() async throws {
        let mockNetworkService = MockNetworkService()
        let dataFetcher = DataFetcher(networkService: mockNetworkService)
        
        dataFetcher.fetchData { _ in }
        
        #expect(mockNetworkService.zomboMusicIsLoaded == true)
        
    }
    
    @Test("Test fetching data from fake zombo.com network with successful network call and returns zombo music") func testFetchData2() async throws {
        let fakeNetworkService = FakeNetworkService()
        let dataFetcher = DataFetcher(networkService: fakeNetworkService)
        var completionData: Data?
        
        dataFetcher.fetchData { data in
            completionData = data
        }
        
        #expect(completionData == nil)
    }
    
    @Test("Test fetching data from stub zombo.com network with successful network call and returns zombo music") func testFetchData3() async throws {
        let data = Data()
        let stubNetworkService = StubNetworkService()
        let dataFetcher = DataFetcher(networkService: stubNetworkService)
        var completionData: Data?
        
        dataFetcher.fetchData { data in
            completionData = data
        }
        #expect(completionData == data)
    }
}
