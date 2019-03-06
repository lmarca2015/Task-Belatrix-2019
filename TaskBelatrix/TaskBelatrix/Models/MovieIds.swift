
//
//  MovieIds.swift
//  TaskBelatrix
//
//  Created by APPLE on 5/03/19.
//  Copyright © 2019 Oxicode. All rights reserved.
//

import UIKit
import SwiftyJSON

class MovieIds: NSObject {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    internal let kIdsTraktKey: String = "trakt"
    internal let kIdsImdbKey: String = "imdb"
    internal let kIdsSlugKey: String = "slug"
    internal let kIdsTmdbKey: String = "tmdb"
    
    
    // MARK: Properties
    public var trakt: Int?
    public var imdb: String?
    public var slug: String?
    public var tmdb: Int?
    
    // MARK: SwiftyJSON Initalizers
    /**
     Initates the class based on the object
     - parameter object: The object of either Dictionary or Array kind that was passed.
     - returns: An initalized instance of the class.
     */
    convenience public init(object: AnyObject) {
        self.init(json: JSON(object))
    }
    
    /**
     Initates the class based on the JSON that was passed.
     - parameter json: JSON object from SwiftyJSON.
     - returns: An initalized instance of the class.
     */
    public init(json: JSON) {
        trakt = json[kIdsTraktKey].int
        imdb = json[kIdsImdbKey].string
        slug = json[kIdsSlugKey].string
        tmdb = json[kIdsTmdbKey].int
        
    }

}
