import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import CloudFoundryEnv
import FoodTruckAPI

HeliumLogger.use()

let trucks: FoodTruck

do {
    Log.info("Attempting init with CF environment")
    let service = try getConfig()
    Log.info("Init with Service")
    trucks = FoodTruck(service: service)
} catch {
    Log.info("Could not retriee CF environment: init with defaults")
    trucks = FoodTruck()
}

let controller = FoodTruckController(backend: trucks)

do {
    let port = try CloudFoundryEnv.getAppEnv().port
    Log.verbose("Assigned port \(port)")
    
    Kitura.addHTTPServer(onPort: port, with: controller.router)
    Kitura.run()
} catch {
    Log.error("Server failed to start!")
}
