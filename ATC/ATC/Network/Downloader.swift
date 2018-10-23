//
//  Downloader.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 22/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation
import AFNetworking

class Downloader {
    
    func makePostRequestWith(urlString: String, data: Data) -> URLRequest?{
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let boundaryConstant = "----------------------App"
        let contentType = "multipart/form-data; boundary=\(boundaryConstant)"
        
        var mutableRequest = URLRequest(url: url)
        mutableRequest.httpMethod = "POST"
        mutableRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        mutableRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        mutableRequest.httpBody = data
        return mutableRequest
    }
    
    func dataFromDictionary(dictionary: Dictionary<String, String>) -> Data {
        var postData = Data()
        let boundaryConstant = "----------------------App"
        
        
        for (key, value) in dictionary {
            postData.append("--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
            
            let param = "Content-Disposition: form-data; name=\"" +  key + "\"\r\n\r\n"
            postData.append(param.data(using: String.Encoding.utf8)!)
            
            let value = value + "\r\n"
            postData.append(value.data(using: String.Encoding.utf8)!)
        }
        postData.append("--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        return postData
        
    }
    
    func getDataFromServer(_ url : String, parameters : Dictionary<String, AnyObject>,  completionHandler: @escaping (_ result : Dictionary<String, AnyObject>?, _ error: String?) -> Void) {
        print(url)
        var urlString = url
        
        urlString = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let manager = AFHTTPSessionManager()
        
        manager.responseSerializer = AFJSONResponseSerializer.init(readingOptions: .allowFragments)
        
        manager.requestSerializer.setValue("application/form-data", forHTTPHeaderField: "Content-Type")
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        
        manager.post(urlString, parameters: parameters, progress: nil, success: { (dataTask, response) in
            print("Reponse -> \(response)")
            if let jsonDictionary = response as? Dictionary<String, AnyObject> {
                completionHandler(jsonDictionary, nil)
            }
            else {
                completionHandler(nil, nil)
            }
        }) { (dataTask, error) in
            print("Error \(error)")
            completionHandler(nil, "Sorry there is some issue!")
        }
        
        //        manager.post(urlString, parameters: parameters, constructingBodyWith: { (formData) in
        //
        //        }, progress: { (progress) in
        //
        //        }, success: { (dataTask, response) in
        //            print("Reponse -> \(response)")
        //            if let jsonDictionary = response as? Dictionary<String, AnyObject> {
        //                completionHandler(jsonDictionary, nil)
        //            }
        //            else {
        //                completionHandler(nil, nil)
        //            }
        //        }) { (dataTask, error) in
        //            print("Error \(error)")
        //            completionHandler(nil, "Sorry there is some issue!")
        //
        //        }
    }
    
    func getDataFromServer1(_ url : String, parameters : Dictionary<String, String>,  completionHandler: @escaping (_ result : Dictionary<String, String>?, _ error: String?) -> Void) {
        print(url)
        var urlString = url
        
        urlString = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let manager = AFHTTPSessionManager()
        
        manager.responseSerializer = AFJSONResponseSerializer.init(readingOptions: .allowFragments)
        
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        
        manager.post(urlString, parameters: parameters, progress: nil, success: { (dataTask, response) in
            print("Reponse -> \(response)")
            if let jsonDictionary = response as? Dictionary<String, String> {
                completionHandler(jsonDictionary, nil)
            }
            else {
                completionHandler(nil, nil)
            }
        }) { (dataTask, error) in
            print("Error \(error)")
            completionHandler(nil, "Sorry there is some issue!")
        }
        
        //        manager.post(urlString, parameters: parameters, constructingBodyWith: { (formData) in
        //
        //        }, progress: { (progress) in
        //
        //        }, success: { (dataTask, response) in
        //            print("Reponse -> \(response)")
        //            if let jsonDictionary = response as? Dictionary<String, AnyObject> {
        //                completionHandler(jsonDictionary, nil)
        //            }
        //            else {
        //                completionHandler(nil, nil)
        //            }
        //        }) { (dataTask, error) in
        //            print("Error \(error)")
        //            completionHandler(nil, "Sorry there is some issue!")
        //
        //        }
    }
    
    func getDataFromServer(_ url : String, parameters : Dictionary<String, AnyObject>, image : UIImage,  completionHandler: @escaping (_ result : Dictionary<String, AnyObject>?, _ error: String?) -> Void) {
        print(url)
        var urlString = url
        
        urlString = urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let manager = AFHTTPSessionManager()
        
        manager.responseSerializer = AFJSONResponseSerializer.init(readingOptions: .mutableContainers)
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        
//        let data = UIImageJPEGRepresentation(image, 0.5)
//
//        manager.post(urlString, parameters: parameters, constructingBodyWith: { (formData) in
//            formData.appendPart(withFileData: data!, name: "received_file", fileName: "attachment.jpg", mimeType: "image/jpeg")
//        }, progress: { (progress) in
//
//        }, success: { (dataTask, response) in
//            print("Response -> \(response)")
//            if let jsonDictionary = response as? Dictionary<String, AnyObject> {
//                completionHandler(jsonDictionary, nil)
//            }
//            else {
//                completionHandler(nil, nil)
//            }
//        }) { (dataTask, error) in
//            print("Error \(error)")
//            completionHandler(nil, "Sorry there is some issue!")
//
//        }
    }
}
