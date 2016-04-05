//
//  WeatherService.swift
//  PrettyWeatherApp
//
//  Created by Yinhuan Yuan on 4/4/16.
//  Copyright © 2016 Yinhuan Yuan. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RxCocoa
import RxSwift
import Alamofire
import SwiftyJSON

class WeatherService {
    private let API_KEY = "095eb77daa24bf8152689693f524407a"
    private let defaultWeatherForecast = WeatherForecast(
        currentWeatherCondition: WeatherCondition(cityName: "", weather: "", icon: .i01d, time: NSDate(), tempKelvin: 273.15, maxTempKelvin: 273.15, minTempKelvin: 273.15),
        hourlyWeatherConditions: (0..<7).map{_ in
            return WeatherCondition(cityName: "", weather: "", icon: .i01d, time: NSDate(), tempKelvin: 273.15, maxTempKelvin: 273.15, minTempKelvin: 273.15)
        },
        dailyWeatherConditions: (0..<7).map{_ in
            return WeatherCondition(cityName: "", weather: "", icon: .i01d, time: NSDate(), tempKelvin: 273.15, maxTempKelvin: 273.15, minTempKelvin: 273.15)
        }
    )
    static let instance = WeatherService()
    
    private init() {
        
    }
    
    func getDefaultWeatherForecast () -> WeatherForecast {
        return defaultWeatherForecast
    }
    
    func createWeatherConditionFronJson(json: JSON) -> WeatherCondition{
        let name = json["name"].string
        let weather = json["weather"][0]["main"].stringValue
        let icon = json["weather"][0]["icon"].stringValue
        let dt = json["dt"].doubleValue
        let time = NSDate(timeIntervalSince1970: dt)
        let tempKelvin = json["main"]["temp"].doubleValue
        let maxTempKelvin = json["main"]["temp_max"].doubleValue
        let minTempKelvin = json["main"]["temp_min"].doubleValue
        
        return WeatherCondition(
            cityName: name,
            weather: weather,
            icon: IconType(rawValue: icon),
            time: time,
            tempKelvin: tempKelvin,
            maxTempKelvin: maxTempKelvin,
            minTempKelvin: minTempKelvin)
    }
    
    func createDayForecastFronJson(json: JSON) -> WeatherCondition{
        let name = ""
        let weather = json["weather"][0]["main"].stringValue
        let icon = json["weather"][0]["icon"].stringValue
        let dt = json["dt"].doubleValue
        let time = NSDate(timeIntervalSince1970: dt)
        let tempKelvin = json["temp"]["day"].doubleValue
        let maxTempKelvin = json["temp"]["max"].doubleValue
        let minTempKelvin = json["temp"]["min"].doubleValue
        
        return WeatherCondition(
            cityName: name,
            weather: weather,
            icon: IconType(rawValue: icon),
            time: time,
            tempKelvin: tempKelvin,
            maxTempKelvin: maxTempKelvin,
            minTempKelvin: minTempKelvin)
    }
    
    func retrieveCurrentWeatherForecast(location: CLLocationCoordinate2D) -> Observable<(WeatherCondition)> {
        return Observable.create { observer in
            let url = "http://api.openweathermap.org/data/2.5/weather?APPID=\(self.API_KEY)"
            let params = ["lat":location.latitude, "lon":location.longitude]
            
            Alamofire.request(.GET, url, parameters: params)
                .responseJSON { request, response, result in
                    switch result {
                    case .Success(let json):
                        let json = JSON(json)
                        observer.on(.Next(self.createWeatherConditionFronJson(json)))
                        observer.on(.Completed)
                    case .Failure(_, let error):
                        observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    }
            }
            return NopDisposable.instance
        }
    }

    func retrieveHourlyWeatherForecast(location: CLLocationCoordinate2D) -> Observable<(Array<WeatherCondition>)> {
        return Observable.create { observer in
            let url = "http://api.openweathermap.org/data/2.5/forecast?APPID=\(self.API_KEY)"
            let params = ["lat":location.latitude, "lon":location.longitude]
            
            Alamofire.request(.GET, url, parameters: params)
                .responseJSON { request, response, result in
                    switch result {
                    case .Success(let json):
                        let json = JSON(json)
                        let list: Array<JSON> = json["list"].arrayValue
                        let weatherConditions: Array<WeatherCondition> = list.map() {
                            return self.createWeatherConditionFronJson($0)
                        }
                        observer.on(.Next(weatherConditions))
                        observer.on(.Completed)
                    case .Failure(_, let error):
                        observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    }
            }
            return NopDisposable.instance
        }
    }

    func retrieveDailyWeatherForecast(location: CLLocationCoordinate2D) -> Observable<(Array<WeatherCondition>)> {
        return Observable.create { observer in
            let url = "http://api.openweathermap.org/data/2.5/forecast/daily?APPID=\(self.API_KEY)"
            let params = ["lat":location.latitude, "lon":location.longitude, "cnt":Double(7+1)]
            
            Alamofire.request(.GET, url, parameters: params)
                .responseJSON { request, response, result in
                    switch result {
                    case .Success(let json):
                        let json = JSON(json)
                        let list: Array<JSON> = json["list"].arrayValue
                        let weatherConditions: Array<WeatherCondition> = list.map() {
                            return self.createDayForecastFronJson($0)
                        }
                        let count = weatherConditions.count
                        let daysWithoutToday = Array(weatherConditions[1..<count])
                        observer.on(.Next(daysWithoutToday))
                        observer.on(.Completed)
                    case .Failure(_, let error):
                        observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    }
            }
            return NopDisposable.instance
        }
    }

    func getWeatherForecast(location: CLLocationCoordinate2D) -> Driver<WeatherForecast> {
        let locationObservable = Observable<CLLocationCoordinate2D>.just(location)
        let currentWeatherForecastObserable = locationObservable.flatMap(retrieveCurrentWeatherForecast)
        let hourlyWeatherForecastObserable = locationObservable.flatMap(retrieveHourlyWeatherForecast)
        let dailyWeatherForecastObserable = locationObservable.flatMap(retrieveDailyWeatherForecast)
        
        return Observable.combineLatest(currentWeatherForecastObserable, hourlyWeatherForecastObserable, dailyWeatherForecastObserable) {
            WeatherForecast(
                currentWeatherCondition: $0,
                hourlyWeatherConditions: $1,
                dailyWeatherConditions: $2
            )
        }.asDriver(onErrorJustReturn: defaultWeatherForecast)
    }
}
