//
//  FoodTruckController.swift
//  FoodTruckAPI
//
//  Created by Falco, Danny (CORP) on 9/16/17.
//
//

import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON

public final class FoodTruckController {
    public let trucks: FoodTruckAPI
    public let router = Router()
    public let trucksPath = "api/v1/trucks"
    
    public init(backend: FoodTruckAPI) {
        self.trucks = backend
        routeSetup()
    }
    
    public func routeSetup() {
        
        router.all("/*",  middleware: BodyParser())
        
        //Food Truck Handling
        //All Trucks
        router.get(trucksPath, handler: getTrucks)
        
        //Add Truck
        router.post(trucksPath, handler: addTruck)
        
        //Get Specific Truck
        router.get("\(trucksPath)/:id", handler: getTruckById)
        
        //Delete Truck
        router.delete("\(trucksPath)/:id", handler: deleteTruckById)
        
    }
    
    private func getTrucks(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        Log.info("INSIDE GET TRUCKS")
        trucks.getAllTrucks { (trucks, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                guard let trucks = trucks else {
                    try response.status (.internalServerError).end()
                    Log.error("Failed to get trucks")
                    return
                }
                
                let json = JSON(trucks.toDict())
                try response.status(.OK).send(json: json).end()
            }
            catch {
                Log.error("Communications error")
            }
        }
    }
    
    private func addTruck(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }
        
        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Invalid JSON data supplied")
            return
        }
        
        let name: String = json["name"].stringValue
        let foodType: String = json["foodtype"].stringValue
        let avgCost: Float = json["avgcost"].floatValue
        let latitude: Float = json["latitude"].floatValue
        let longitude: Float = json["longitude"].floatValue
        
        guard name != "" else {
            response.status(.badRequest)
            Log.error("Required field not supplied")
            return
        }
        
        trucks.addTruck(name: name, foodType: foodType, avgCost: avgCost, latitude: latitude, longitude: longitude)  { (truck, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                
                guard let truck = truck else {
                    try response.status(.internalServerError).end()
                    Log.error("Truck not found")
                    return
                }
                
                let result = JSON(truck.toDict())
                Log.info("\(name) added to vehicle list")
                do {
                    try response.status(.OK).send(json: result).end()
                }
                catch {
                    Log.error("Error sending response")
                }
            }
            catch {
                Log.error("Communications error")
            }
        }
    }
    
    private func getTruckById(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let docId = request.parameters["id"] else {
            response.status(.badRequest)
            Log.error("No Id supplied")
            return
        }
        
        trucks.getTruck(docId: docId) { (truck, err) in
            do {
                guard err == nil else {
                    try response.status(.badRequest).end()
                    Log.error(err.debugDescription)
                    return
                }
                
                if let truck = truck {
                    let result = JSON(truck.toDict())
                    try response.status(.OK).send(json: result).end()
                }
                else {
                    Log.warning("Could not find a truck by that Id")
                    response.status(.notFound)
                    return
                }
            }
            catch {
                Log.error("Communications Error")
            }
        }
    }
    
    private func deleteTruckById(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let docId = request.parameters["id"] else {
            response.status(.badRequest)
            Log.warning("Id not found in request")
            return
        }
        
        trucks.deleteTruck(docId: docId) { (err) in
            do {
                
                guard err == nil else {
                try response.status(.badRequest).end()
                Log.error(err.debugDescription)
                return
                }
                try response.status(.OK).end()
                Log.info("\(docId) successfully deleted")
            }
            catch {
                Log.error("Communications Error")
            }
        }
    }
}
