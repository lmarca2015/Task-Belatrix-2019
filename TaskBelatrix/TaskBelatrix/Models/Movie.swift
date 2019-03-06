//
//  Movie.swift
//  TaskBelatrix
//
//  Created by APPLE on 5/03/19.
//  Copyright © 2019 Oxicode. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class Movie: NSObject {
    
    internal let kMovieTitleKey: String = "title"
    internal let kMovieRuntimeKey: String = "runtime"
    internal let kMovieOverviewKey: String = "overview"
    internal let kMovieHomepageKey: String = "homepage"
    internal let kMovieYearKey: String = "year"
    internal let kMovieCertificationKey: String = "certification"
    internal let kMovieTrailerKey: String = "trailer"
    internal let kMovieGenresKey: String = "genres"
    internal let kMovieRatingKey: String = "rating"
    internal let kMovieAvailableTranslationsKey: String = "available_translations"
    internal let kMovieReleasedKey: String = "released"
    internal let kMovieTaglineKey: String = "tagline"
    internal let kMovieUpdatedAtKey: String = "updated_at"
    internal let kMovieVotesKey: String = "votes"
    internal let kMovieLanguageKey: String = "language"
    internal let kMovieIdsKey: String = "ids"
    
    
    // MARK: Properties
    public var title: String?
    public var runtime: Int?
    public var overview: String?
    public var homepage: String?
    public var year: Int?
    public var certification: String?
    public var trailer: String?
    public var genres: [String]?
    public var rating: Float?
    public var availableTranslations: [String]?
    public var released: String?
    public var tagline: String?
    public var updatedAt: String?
    public var votes: Int?
    public var language: String?
    public var ids: MovieIds?
    public var imageURL: String?
    
    
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
        title = json[kMovieTitleKey].string
        runtime = json[kMovieRuntimeKey].int
        overview = json[kMovieOverviewKey].string
        homepage = json[kMovieHomepageKey].string
        year = json[kMovieYearKey].int
        certification = json[kMovieCertificationKey].string
        trailer = json[kMovieTrailerKey].string
        genres = []
        if let items = json[kMovieGenresKey].array {
            for item in items {
                if let tempValue = item.string {
                    genres?.append(tempValue)
                }
            }
        } else {
            genres = nil
        }
        rating = json[kMovieRatingKey].float
        availableTranslations = []
        if let items = json[kMovieAvailableTranslationsKey].array {
            for item in items {
                if let tempValue = item.string {
                    availableTranslations?.append(tempValue)
                }
            }
        } else {
            availableTranslations = nil
        }
        released = json[kMovieReleasedKey].string
        tagline = json[kMovieTaglineKey].string
        updatedAt = json[kMovieUpdatedAtKey].string
        votes = json[kMovieVotesKey].int
        language = json[kMovieLanguageKey].string
        ids = MovieIds(json: json[kMovieIdsKey])
        
    }
    
    public func setImage(jsonResponse : JSON){
        if let image = jsonResponse["Poster"].string{
            self.imageURL = image
        }
    }

}
