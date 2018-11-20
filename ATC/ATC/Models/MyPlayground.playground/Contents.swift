import UIKit

var str = "Hello, playground"

//http://34.209.125.112/api/favorites/findOne

let scheme = "http"
let host = "34.209.125.112"
let path = "/api/favorites/findOne"
let queryItem = URLQueryItem(name: "filter", value: "{\"where\":{\"user_id\":10}}")


var urlComponents = URLComponents()
urlComponents.scheme = scheme
urlComponents.host = host
urlComponents.path = path
urlComponents.queryItems = [queryItem]

if let url = urlComponents.url {
    print(url)   // "https://www.google.com/search?q=Formula%20One"
}
