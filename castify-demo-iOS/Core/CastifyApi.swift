import Foundation
import Combine

class CastifyApi {
  
  let baseUrl: String
  let token: String
  
  init(_ baseUrl: String, _ token: String) {
    self.baseUrl = baseUrl
    self.token   = token
  }
  
  func listBroadcasts() -> AnyPublisher<Page<Broadcast>, Error> {
    return fetch(request(get: "broadcasts"))
      .tryMap { (data) throws in
        return try JSONDecoder().decode(Page<Broadcast>.self, from: data)
      }
      .eraseToAnyPublisher()
  }

  private func request(get path: String) -> URLRequest {
    guard let url = URL(string: "\(baseUrl)/\(path)") else {
      fatalError()
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    return request
  }

}

let castifyApi = CastifyApi(castifyApp.config.restAPI, castifyApp.token)

struct Page<T: Decodable>: Decodable {
  var values: [T] = []
  var total = 0
}

struct Broadcast : Decodable {
  var broadcastId: String
  var name: String? = nil
  var link: String? = nil
  var startedAt: Int64
  var stoppedAt: Int64? = nil
}

extension Broadcast: Identifiable {
  
  typealias ID = String
  
  var id: ID { broadcastId }
}

fileprivate func fetch(_ request: URLRequest) -> AnyPublisher<Data, Error> {
  return URLSession
    .shared
    .dataTaskPublisher(for: request)
    .tryMap { (data, resp) throws in
      guard let aux = resp as? HTTPURLResponse, aux.statusCode == 200 else {
        throw MyError()
      }
      return data
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

struct MyError: Error {
}
