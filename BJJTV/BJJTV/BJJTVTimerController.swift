//
//  BJJTVTimerController.swift
//  BJJTV
//
//  Created by BenRussell on 5/17/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import Foundation

protocol BJJTVTimerControllerDelegate {
    func timeChanged()
}

class BJJTVTimerController:NSObject {
    
    var delegate:BJJTVTimerControllerDelegate?
    var seconds:Int?
    var timer = Timer()
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(BJJTVTimerController.timeChanged), userInfo: nil, repeats: true)
    }
    
    func stopTime() {
        timer.invalidate()
    }
    
    func timeChanged() {
        // Update time
        seconds! -= 1
        // Send notification
        delegate?.timeChanged()
    }
    
}
