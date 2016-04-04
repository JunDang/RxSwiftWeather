//
//  GeolocationService.swift
//  PrettyWeatherApp
//
//  Created by Yinhuan Yuan on 4/3/16.
//  Copyright © 2016 Yinhuan Yuan. All rights reserved.
//

import Foundation
import CoreLocation
import RxCocoa

class GeolocationService {
    static let instance = GeolocationService()
    private (set) var autorized: Driver<Bool>
    private (set) var location: Driver<CLLocationCoordinate2D>
    
    private let locationManager = CLLocationManager()
    
    private init() {
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        autorized = locationManager.rx_didChangeAuthorizationStatus
            .startWith(CLLocationManager.authorizationStatus())
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.NotDetermined)
            .map {
                switch $0 {
                case .AuthorizedAlways:
                    return true
                default:
                    return false
                }
        }
        location = locationManager.rx_didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .filter { $0.count > 0 }
            .map { $0.last!.coordinate }
            .throttle(0.5)
            .distinctUntilChanged({ (lhs, rhs) -> Bool in
                fabs(lhs.latitude - rhs.latitude) <= 0.0000001 && fabs(lhs.longitude - rhs.longitude) <= 0.0000001
            })
                
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    func getLocation() -> Driver<CLLocationCoordinate2D> {
        return location
    }
}
