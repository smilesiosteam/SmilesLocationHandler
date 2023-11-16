//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesUtilities

class SetLocationViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getCities
    }
    
    enum Output {
        case fetchCitiesDidSucceed(response: GetCitiesResponse)
        case fetchCitiesDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension SetLocationViewModel {
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getCities:
                self?.getCities()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
}

// MARK: - API CALLS -
extension SetLocationViewModel {
    
    private func getCities() {
        let getCitiesRequest = GetCitiesRequest(isGuestUser: AppCommonMethods.isGuestUser)
        let service = SetLocationRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            baseUrl: AppCommonMethods.serviceBaseUrl,
            endPoint: .getCities
        )
        
        service.getCitiesService(request: getCitiesRequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchCitiesDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.fetchCitiesDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    
}
