import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = ISO8601DateFormatter().date(from: result.createdAt)
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
        
    }
    
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

final class ImagesListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    private var currentTask: URLSessionTask?
    
    private let perPage = 10
    
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
            guard let self else { return }
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
