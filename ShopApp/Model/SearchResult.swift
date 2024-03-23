//
//  SearchResult.swift
//  ShopApp
//
//  Created by A'zamjon Abdumuxtorov on 16/03/24.
//

import Foundation

class SearchResult: Codable{
    
    var trackName:String? = ""
    var artistName:String? = ""
    var trackPrice:Double? = 0.0
    var imageSmall:String? = ""
    var imageLarge:String? = ""
    var storeUrl:String? = ""
    var genre:String? = ""
    var kind = ""
    
    var name: String{
        return trackName ?? ""
    }
    
    enum Codingkeys: String,CodingKey{
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case storeUrl = "trackViewUrl"
        case genre = "primaryGenreName"
        case trackName,artistName,trackPrice,kind
        
    }
}

class ResultArray: Codable{
    var resultCount:Int = 0
    var results: [SearchResult]? = []
}
