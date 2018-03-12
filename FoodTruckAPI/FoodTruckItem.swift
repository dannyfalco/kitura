//
//  FoodTruckItem.swift
//  FoodTruckAPI
//
//  Created by Falco, Danny (CORP) on 9/19/17.
//
//

import Foundation

typealias JSONDictionary = [String: Any]

protocol DictionaryConvertable {
    func toDict() -> JSONDictionary
}

public struct FoodTruckItem {
    
    public let docId: String
    public let name: String
    public let foodType: String
    public let avgCost: Float
    public let latitude: Float
    public let longitude: Float
    
    public init(docId: String, name: String, foodType: String, avgCost: Float, latitude: Float, longitude: Float) {
        
        self.docId = docId
        self.name = name
        self.foodType = foodType
        self.avgCost = avgCost
        self.latitude = latitude
        self.longitude = longitude
    }
    
}

extension FoodTruckItem: Equatable {
    public static func == (lhs: FoodTruckItem, rhs: FoodTruckItem) -> Bool {
        return lhs.docId == rhs.docId &&
            lhs.name == rhs.name &&
            lhs.foodType == rhs.foodType &&
            lhs.avgCost == rhs.avgCost &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude
    }
}

extension FoodTruckItem: DictionaryConvertable {
    func toDict() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = self.docId
        result["name"] = self.name
        result["foodType"] = self.foodType
        result["avgCost"] = self.avgCost
        result["latitude"] = self.latitude
        result["longitude"] = self.longitude
        
        return result
    }
}


extension Array where Element: DictionaryConvertable {
    func toDict() -> [JSONDictionary] {
        return self.map {$0.toDict() }
    }
}

