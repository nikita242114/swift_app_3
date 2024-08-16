// Блок 1
import Foundation

class NetworkService {
    
    func getLocations() {
        let url = URL(string: "https://kudago.com/public-api/v1.2/locations/?lang=ru&fields=timezone,name,currency,coords")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let locations = try JSONDecoder().decode([Location].self, from: data)
                    for location in locations {
                        print("Location Name: \(location.name)")
                        print("Timezone: \(location.timezone)")
                        print("Currency: \(location.currency)")
                        print("Coords: \(location.coords)")
                        print("---")
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    func getErrorMessage(code: Int) {
        let url = URL(string: "https://http.cat/\(code)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    print("Error Message: \(errorMessage)")
                }
            }
        }.resume()
    }
    
    func getNews() {
        let url = URL(string: "https://docs.kudago.com/api/news")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                    let news = newsResponse.results.filter { $0.is_actual == true }
                    for newsItem in news {
                        print("Publication Date: \(newsItem.publication_date)")
                        print("Title: \(newsItem.title)")
                        print("Description: \(newsItem.description)")
                        print("Body Text: \(newsItem.body_text)")
                        print("---")
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}

struct Location: Codable {
    let timezone: String
    let name: String
    let currency: String
    let coords: [Double]
}

struct News: Codable {
    let publication_date: String
    let title: String
    let description: String
    let body_text: String
    let is_actual: Bool
}

struct NewsResponse: Codable {
    let results: [News]
}

let networkService = NetworkService()

networkService.getLocations()

networkService.getErrorMessage(code: 404)

networkService.getNews()

// Блок 2

import Foundation

struct Place: Codable {
    let id: Int
    let title: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
    }
}

func getPlaces() {
    let url = URL(string: "https://kudago.com/public-api/v1.4/places/")!
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                let places = try JSONDecoder().decode([Place].self, from: data)
                for place in places {
                    print("Title: \(place.title)")
                    print("Description: \(place.description)")
                    print("---")
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
    }.resume()
}

getPlaces()

import Foundation

struct Movie: Codable {
    let title: String
    let description: String
    let originalCountry: String
    let releaseYear: Int
    let imdbRating: Double
    let siteUrl: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case originalCountry = "original_country"
        case releaseYear = "release_year"
        case imdbRating = "imdb_rating"
        case siteUrl = "site_url"
    }
}

func getMovies() {
    let url = URL(string: "https://kudago.com/public-api/v1.4/movies/")!
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                let movies = try JSONDecoder().decode([Movie].self, from: data)
                for movie in movies {
                    print("Title: \(movie.title)")
                    print("Description: \(movie.description)")
                    print("Original Country: \(movie.originalCountry)")
                    print("Release Year: \(movie.releaseYear)")
                    print("IMDb Rating: \(movie.imdbRating)")
                    print("Site URL: \(movie.siteUrl)")
                    print("---")
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
    }.resume()
}

getMovies()

import Foundation

struct DogImage: Codable {
    let url: String
}

func getDogImages() {
    for _ in 1...6 {
        let url = URL(string: "https://random.dog/woof.json")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let dogImage = try JSONDecoder().decode(DogImage.self, from: data)
                    print("Dog Image URL: \(dogImage.url)")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}

getDogImages()

// Д.З.

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.frame = view.bounds
        
        let url = URL(string: "https://oauth.vk.com/authorize?client_id=YOUR_CLIENT_ID&redirect_uri=https://oauth.vk.com/blank.html&scope=friends,groups,photos&response_type=token&v=5.131")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment else {
            decisionHandler(.allow)
            return
        }
        
        let params = fragment
            .components(separatedBy: "&")
            .reduce(into: [String: String]()) { result, param in
                let keyValue = param.components(separatedBy: "=")
                if keyValue.count == 2 {
                    result[keyValue[0]] = keyValue[1]
                }
            }
        
        let token = params["access_token"]
        let userId = params["user_id"]
        
        print("Access Token: \(token ?? "N/A")")
        print("User ID: \(userId ?? "N/A")")
        
        decisionHandler(.cancel)
        webView.removeFromSuperview()

        if let token = token {
            let friendsViewController = FriendsViewController(token: token)
            navigationController?.pushViewController(friendsViewController, animated: true)
        }
    }
}

class FriendsViewController: UIViewController {
    
    let token: String
    
    init(token: String) {
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Запрос на список друзей
        getFriendsList(token: token)
        // Запрос на список групп
        getGroupsList(token: token)
        // Запрос на список фотографий
        getPhotosList(token: token)
    }
    
    func getFriendsList(token: String) {
        let friendsURL = URL(string: "https://api.vk.com/method/friends.get?access_token=\(token)&v=5.131")!
        URLSession.shared.dataTask(with: friendsURL) { data, response, error in
            if let data = data {
                if let friends = try? JSONSerialization.jsonObject(with: data) {
                    print("Friends List:")
                    print(friends)
                }
            }
        }.resume()
    }
    
    func getGroupsList(token: String) {
        let groupsURL = URL(string: "https://api.vk.com/method/groups.get?access_token=\(token)&v=5.131")!
        URLSession.shared.dataTask(with: groupsURL) { data, response, error in
            if let data = data {
                if let groups = try? JSONSerialization.jsonObject(with: data) {
                    print("Groups List:")
                    print(groups)
                }
            }
        }.resume()
    }
    
    func getPhotosList(token: String) {
        let photosURL = URL(string: "https://api.vk.com/method/photos.getAll?access_token=\(token)&v=5.131")!
        URLSession.shared.dataTask(with: photosURL) { data, response, error in
            if let data = data {
                if let photos = try? JSONSerialization.jsonObject(with: data) {
                    print("Photos List:")
                    print(photos)
                }
            }
        }.resume()
    }
}