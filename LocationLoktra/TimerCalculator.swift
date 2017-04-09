//
//  TimerCalculator.swift
//  LocationLoktra
//
//  Created by Saurabh Yadav on 09/04/17.
//  Copyright © 2017 Saurabh Yadav. All rights reserved.
//

import Foundation

class TimerCalculator {
    let startTime:CFAbsoluteTime
    var endTime:CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}
