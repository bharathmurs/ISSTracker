//
//  ISSService.swift
//  ISSTracker
//
//  Created by Bharath Urs on 8/22/15.
//  Copyright (c) 2015 Urs. All rights reserved.
//

import Foundation
import MapKit

enum RequestType : String {
    case GET = "GET"
}

class ISSService: NSObject {

    let API_URL = NSURL(string: "http://api.open-notify.org/iss-now.json")
    
    private func _getRequestWithType(type: RequestType) -> NSMutableURLRequest {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.HTTPMethod = type.rawValue
        return request
    }
    
    private func sendAsyncRequestWithRequest(request: NSMutableURLRequest, completionHandler: ((NSDictionary!) -> Void)) {
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            var jsonError: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            if let jsonParse: [String: AnyObject] = (NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: jsonError) as? [String: AnyObject]) {
                completionHandler(jsonParse)
            } else {
                var dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println(error)
                println(dataString)
            }
            
        })
    }
    
    func fetchISSLocation(completionHandler: ((CLLocation, String)->Void)) {
        let request = _getRequestWithType(.GET)
        request.URL = API_URL
        
        self.sendAsyncRequestWithRequest(request, completionHandler: { (json) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                var location: CLLocation = CLLocation()
                
                if let iss_position: NSDictionary = json["iss_position"] as? NSDictionary {
                    let latitude = iss_position["latitude"] as? Double
                    let longitude = iss_position["longitude"] as? Double
                    
                    if latitude != nil && longitude != nil {
                        location = CLLocation(latitude: latitude!, longitude: longitude!)
                    }
                }
                
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
                    
                    var annotationTitle = ""

                    func getCityAndCountry(placemark: CLPlacemark) -> String {
                        var cityAndCountry = ""
                        if placemark.locality != nil { cityAndCountry += placemark.locality + ", " }
                        if placemark.country != nil { cityAndCountry += placemark.country }
                        
                       return cityAndCountry
                    }
                    
                    if placemarks.count > 0 {
                        if let placemark = placemarks[0] as? CLPlacemark {
                            annotationTitle = getCityAndCountry(placemark)
                        }
                    }
                    
                    completionHandler(location, annotationTitle)
                })

            })
        })
    }
}
