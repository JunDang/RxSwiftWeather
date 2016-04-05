//
//  WeatherDayForecastView.swift
//  PrettyWeatherApp
//
//  Created by Yinhuan Yuan on 4/3/16.
//  Copyright © 2016 Yinhuan Yuan. All rights reserved.
//

import UIKit
import Cartography
import WeatherIconsKit

class WeatherDayForecastView: UIView {
    private var didSetupConstraints = false
    private let iconLabel = UILabel()
    private let dayLabel = UILabel()
    private let tempsLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func updateConstraints() {
        if didSetupConstraints {
            super.updateConstraints()
            return
        }
        layoutView()
        super.updateConstraints()
        didSetupConstraints = true
    }
}
// MARK: Setup
private extension WeatherDayForecastView{
    func setup(){
        addSubview(dayLabel)
        addSubview(iconLabel)
        addSubview(tempsLabel)
    }
}

// MARK: Layout
private extension WeatherDayForecastView{
    func layoutView() {
        constrain(self) {
            $0.height == 50
        }
        
        constrain(iconLabel) {
            $0.centerY == $0.superview!.centerY
            $0.left == $0.superview!.left + 20
            $0.width == $0.height
            $0.height == 50
        }
        
        constrain(dayLabel, iconLabel) {
            $0.centerY == $0.superview!.centerY
            $0.left == $1.right + 20
        }
        
        constrain(tempsLabel) {
            $0.centerY == $0.superview!.centerY
            $0.right == $0.superview!.right - 20
        }
    }
}

// MARK: Style
private extension WeatherDayForecastView{
    func style(){
        iconLabel.textColor = UIColor.whiteColor()
        dayLabel.font = UIFont.latoFontOfSize(20)
        dayLabel.textColor = UIColor.whiteColor()
        tempsLabel.font = UIFont.latoFontOfSize(20)
        tempsLabel.textColor = UIColor.whiteColor()
    }
}


// MARK: Render
extension WeatherDayForecastView{
    func render(weatherCondition: WeatherCondition){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dayLabel.text = dateFormatter.stringFromDate(weatherCondition.time)
        iconLabel.attributedText = iconStringFromIcon(weatherCondition.icon!, size: 30)
        
        var usesMetric = false
        if let localeSystem = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem) as? Bool {
            usesMetric = localeSystem
        }
        
        if usesMetric {
            tempsLabel.text = "\(weatherCondition.minTempCelsius.roundToInt())°     \(weatherCondition.maxTempCelsius.roundToInt())°"
        } else {
            tempsLabel.text = "\(weatherCondition.minTempFahrenheit.roundToInt())°     \(weatherCondition.maxTempFahrenheit.roundToInt())°"
        }
        /*
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dayLabel.text = dateFormatter.stringFromDate(NSDate())
        iconLabel.attributedText = WIKFontIcon.wiDaySunnyIconWithSize(30).attributedString()
        
        tempsLabel.text = "7°     11°"*/
    }
}