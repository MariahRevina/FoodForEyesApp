import Foundation


final class ImagesListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    private var currentTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    
    private let perPage = 10
    
    // MARK: - Fetch Photos
    
    func fetchPhotosNextPage() {
        
        guard currentTask == nil else {
            print("Загрузка фото в ленту уже идет, новый запрос отменяем")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = createRequest(for: nextPage) else {
            print("Не удалось сложить запрос для загрузки фото")
            return
        }
        
        currentTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult],Error>) in
            guard let self = self else { return }
            defer {
                self.currentTask = nil
            }
            switch result {
            case .success(let photoResults):
                var newPhotos: [Photo] = []
                for photoResult in photoResults {
                    let photo = Photo(from: photoResult)
                    newPhotos.append(photo)
                }
                
                DispatchQueue.main.async {
                    self.lastLoadedPage = nextPage
                    self.photos.append(contentsOf: newPhotos)
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    
                    print("Успешно загружено \(newPhotos.count) фото. Всего фото: \(self.photos.count)")
                }
            case .failure(let error):
                print("Ошибка загрузки страницы \(nextPage): \(error.localizedDescription)")
            }
        }
        currentTask?.resume()
    }
    
    // MARK: - Change Like
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void,Error>) -> Void) {
        likeTask?.cancel()
        
        guard let request = createLikeRequest(photoId: photoId, isLike: isLike)
        else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        likeTask = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }
            
            if(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: {$0.id == photoId}) {
                        var updatedPhoto = self.photos[index]
                        updatedPhoto.isLiked = isLike
                        self.photos[index] = updatedPhoto
                        
                        let updatedIndexPath = IndexPath(row: index, section: 0)
                        
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self,  userInfo: ["updatedIndexPath": updatedIndexPath])
                        completion(.success(()))
                    } else {
                        completion(.failure(NSError(
                            domain: "ImagesListService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Фото с id \(photoId) не найдено"])))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "ImagesListService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера: \(httpResponse.statusCode)"])))
                }
            }
        }
        likeTask?.resume()
    }
    
    // MARK: - Private Methods
    
    private func createLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            print("Неверный URL для лайка")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Токена нет")
            return nil
        }
        return request
    }
    
    private func createRequest(for page: Int) -> URLRequest? {
        
        var components = URLComponents(string: "https://api.unsplash.com/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        guard let url =  components?.url else {
            print("Урл для загрузки картинок не собрался")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Токена нет")
            return nil
        }
        return request
    }
    
}
