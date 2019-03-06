//
//  APITrakt.swift
//  TaskBelatrix
//
//  Created by APPLE on 5/03/19.
//  Copyright © 2019 Oxicode. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class APITrakt: NSObject {
    
    // MARK - SERVER CONNECTIONS
    
    public func downloadMovies(pageNumber : Int, arrayResults : NSMutableArray){
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "trakt-api-version" : kAPI_VERSION,
            "trakt-api-key" : kAPI_CLIENT_ID
        ]
        
        let urlRequest = kAPI_URL + kAPI_GET_MOVIES + "&page=" + String(pageNumber)
        //print("Request: \(urlRequest)")
        
        Alamofire.request(urlRequest, headers: headers).responseJSON { response in
            if let jsonRawResponse = response.result.value{
                
                let jsonResult = JSON(jsonRawResponse)
                print("JSON: \(jsonResult)")
                self.getPoster(result: jsonResult, arrayResults: arrayResults)
                
            }else{
                
                self.dismissOperation();
                
            }
        }
    }
    
    public func searchMovies(pageNumber : Int, arrayResults : NSMutableArray, searchTerms : String){
        
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "trakt-api-version" : kAPI_VERSION,
            "trakt-api-key" : kAPI_CLIENT_ID
        ]
        
        let urlRequest = kAPI_URL + kAPI_GET_SEARCH_MOVIES + searchTerms.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "&page=" + String(pageNumber)
        //print("Request: \(urlRequest)")
        
        print(urlRequest)
        
        Alamofire.request(urlRequest, headers: headers).responseJSON { response in
            if let jsonRawResponse = response.result.value{
                
                //print("JSON: \(jsonRawResponse)")
                let jsonResult = JSON(jsonRawResponse)
                print("cant  \(jsonResult.count)")
                
                if jsonResult.count > 0{
                    
                    print("JSON: \(jsonResult)")
                    
                    self.getPoster(result: jsonResult, arrayResults: arrayResults)
                    
                }else{
                    
                    print("No se encontraron resultados.")
                    
                    self.dismissOperation()
                    
                }
                
            }else{
                
                self.dismissOperation()
                
            }
        }
    }
    
    // Handler to get poster image
    public func getPoster(result : JSON, arrayResults : NSMutableArray){
        
        for i in 0  ..< result.count  {
            let movie = Movie(json: result[i]["movie"])
            self.getImage(movie: movie, arrayResults: arrayResults, currentItemIndex: i, totalItems: result.count)
        }
        
        
    }
    
    // Request poster image to API OMDB
    public func getImage(movie : Movie, arrayResults : NSMutableArray, currentItemIndex : Int, totalItems : Int){
        
        if let imdb = movie.ids?.imdb{
            
            let urlRequest = (kAPI_GET_IMAGES + imdb)
            
            Alamofire.request(urlRequest).responseJSON { response in
                if let jsonRawResponse = response.result.value{
                    
                    let jsonResult = JSON(jsonRawResponse)
                    movie.setImage(jsonResponse: jsonResult)
                    
                    arrayResults.add(movie)
                    
                    if currentItemIndex == (totalItems - 1) {
                        self.showResults()
                    }
                    
                }else{
                    
                    self.dismissOperation()
                    
                }
            }
        }else{
            arrayResults.add(movie)
            
            if currentItemIndex == (totalItems - 1) {
                self.showResults()
            }
        }
    }
    
    public func showResults(){
        
        let pref = UserDefaults.standard
        pref.set(false, forKey: "isPageRefreshing")
        pref.synchronize()
        
        // Define identifier
        let notificationName = Notification.Name("needUpdateTable")
        
        // Post notification
        NotificationCenter.default.post(name: notificationName, object: nil)
        
    }
    
    public func dismissOperation(){
        
        let pref = UserDefaults.standard
        pref.set(false, forKey: "isInSearchPhase")
        pref.set(false, forKey: "isPageRefreshing")
        pref.synchronize()
        
        // Define identifier
        let notificationName = Notification.Name("needUpdateTable")
        
        // Post notification
        NotificationCenter.default.post(name: notificationName, object: nil)
        
    }

}
