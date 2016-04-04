//
//  FlickrService.swift
//  PrettyWeatherApp
//
//  Created by Yinhuan Yuan on 4/3/16.
//  Copyright © 2016 Yinhuan Yuan. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RxCocoa
import RxSwift
import FlickrKit

extension FlickrKit {
    public func retrieveImage(location: CLLocationCoordinate2D) -> Observable<(UIImage!)> {
        return Observable.create { observer in
            self.call("flickr.photos.search", args: [
                "group_id": "1463451@N25",
                "lat": "\(location.latitude)",
                "lon": "\(location.longitude)",
                "radius": "10"
            ], maxCacheAge: FKDUMaxAgeOneHour) { (response, error) -> Void in
                guard let response = response else {
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    return
                }
                guard let responseInArray = response as? [String:AnyObject], photos = responseInArray["photos"] as? [String:AnyObject], listOfPhotos: AnyObject = photos["photo"] else {
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    return
                }
                if listOfPhotos.count == 0 {
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    return
                }
                let randomIndex = Int(arc4random_uniform(UInt32(listOfPhotos.count)))
                let photo = listOfPhotos[randomIndex] as! [String:AnyObject]
                let url = self.photoURLForSize(FKPhotoSizeMedium640,
                    fromPhotoDictionary: photo)
                let image = UIImage(data: NSData(contentsOfURL: url)!)
                observer.on(.Next(image))
                observer.on(.Completed)
            }
            return NopDisposable.instance
        }
    }
}

class FlickrService {
    private let OBJECTIVE_FLICKR_API_KEY = "604f43c7c2e544f47118a96b53bc4428"
    private let OBJECTIVE_FLICKR_API_SHARED_SECRET = "b2209c2254521a94"
    //private let GROUP_ID = "1463451@N25"
    private let fk = FlickrKit.sharedFlickrKit()
    
    static let instance = FlickrService()
    
    private init() {
        fk.initializeWithAPIKey(OBJECTIVE_FLICKR_API_KEY, sharedSecret: OBJECTIVE_FLICKR_API_SHARED_SECRET)
    }
    
    func getBackgroundImage(location: CLLocationCoordinate2D) -> Driver<UIImage!> {
        return Observable<CLLocationCoordinate2D>.just(location)
            .flatMap(fk.retrieveImage)
            .asDriver(onErrorJustReturn: UIImage(named: "DefaultImage"))
    }
}
