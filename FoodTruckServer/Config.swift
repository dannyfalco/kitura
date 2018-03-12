//
//  Config.swift
//  FoodTruckAPI
//
//  Created by Falco, Danny (CORP) on 8/6/17.
//
//

import Foundation
import LoggerAPI
import CouchDB
import CloudFoundryEnv

struct ConfigError: LocalizedError {
    var errorDescription: String? {
        return "Could not retrieve config info"
    }
}

func getConfig() throws -> Service {
    var appEnv: AppEnv?
    
    do {
        Log.warning("Attempting to retrieve CF Environment")
        appEnv = try CloudFoundryEnv.getAppEnv()
        
        let services = appEnv!.getServices()
        let servicePair = services.filter { element in element.value.label ==
            "cloudantNoSQLDB"}.first
        guard let service = servicePair?.value else {
            throw ConfigError()
        }
        
        return service
    } catch {
        Log.warning("An error occurred while trying to retrieve configs")
        throw ConfigError()
    }
}
