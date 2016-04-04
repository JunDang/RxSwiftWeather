//
//  CurrentWeatherView.swift
//  PrettyWeatherApp
//
//  Created by Yinhuan Yuan on 4/1/16.
//  Copyright © 2016 Yinhuan Yuan. All rights reserved.
//

import UIKit
import Cartography
import LatoFont
import WeatherIconsKit

class CurrentWeatherView: UIView {
    static var HEIGHT: CGFloat { get { return 160} }
    private var didSetupConstraints = false
    private let cityLbl = UILabel()
    private let maxTempLbl = UILabel()
    private let minTempLbl = UILabel()
    private let iconLbl = UILabel()
    private let weatherLbl = UILabel()
    private let currentTempLbl = UILabel()
    
    override init (frame: CGRect) {
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

private extension CurrentWeatherView {
    func setup() {
        addSubview(cityLbl)
        addSubview(currentTempLbl)
        addSubview(maxTempLbl)
        addSubview(minTempLbl)
        addSubview(iconLbl)
        addSubview(weatherLbl)
    }
}

private extension CurrentWeatherView {
    func layoutView() {
        constrain(self) {
            $0.height == CurrentWeatherView.HEIGHT
        }
        
        constrain(iconLbl) {
            $0.top == $0.superview!.top
            $0.left == $0.superview!.left + 20
            $0.width == 30
            $0.width == $0.height
        }

        constrain(weatherLbl, iconLbl) {
            $0.top == $1.top
            $0.left == $1.right + 10
            $0.height == $1.height
            $0.width == 200
        }
        
        constrain(currentTempLbl, iconLbl) {
            $0.top == $1.bottom
            $0.left == $1.left
        }
        
        constrain(currentTempLbl, minTempLbl) {
            $0.bottom == $1.top
            $0.left == $1.left
        }
        
        constrain(minTempLbl) {
            $0.bottom == $0.superview!.bottom
            $0.height == 30
        }
        
        constrain(maxTempLbl, minTempLbl) {
            $0.top == $1.top
            $0.height == $1.height
            $0.left == $1.right + 10
        }
        constrain(cityLbl) {
            $0.bottom == $0.superview!.bottom
            $0.right == $0.superview!.right - 10
            $0.height == 30
            $0.width == 200
        }
    }
}

private extension CurrentWeatherView {
    func style() {
        iconLbl.textColor = UIColor.whiteColor()
        weatherLbl.font = UIFont.latoLightFontOfSize(20)
        weatherLbl.textColor = UIColor.whiteColor()
        
        currentTempLbl.font = UIFont.latoLightFontOfSize(96)
        currentTempLbl.textColor = UIColor.whiteColor()
        
        maxTempLbl.font = UIFont.latoLightFontOfSize(18)
        maxTempLbl.textColor = UIColor.whiteColor()
        
        minTempLbl.font = UIFont.latoLightFontOfSize(18)
        minTempLbl.textColor = UIColor.whiteColor()
        
        cityLbl.font = UIFont.latoLightFontOfSize(18)
        cityLbl.textColor = UIColor.whiteColor()
        cityLbl.textAlignment = .Right
    }
}

// MARK: Render
extension CurrentWeatherView{
    func render(){
        iconLbl.attributedText = WIKFontIcon.wiDaySunnyIconWithSize(20).attributedString()
        weatherLbl.text = "Sunny"
        
        minTempLbl.text = "4°"
        maxTempLbl.text = "10°"
        currentTempLbl.text = "6°"
        
        cityLbl.text = "London"
    }
}