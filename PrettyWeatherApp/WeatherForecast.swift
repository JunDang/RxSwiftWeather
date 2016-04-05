//
//  WeatherForecast.swift
//  PrettyWeatherApp
//
//  Created by Yinhuan Yuan on 4/4/16.
//  Copyright © 2016 Yinhuan Yuan. All rights reserved.
//

import Foundation
struct WeatherForecast {
    let currentWeatherCondition: WeatherCondition
    let hourlyWeatherConditions: Array<WeatherCondition>
    let dailyWeatherConditions: Array<WeatherCondition>
}