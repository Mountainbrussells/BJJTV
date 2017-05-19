//
//  BJJTVRoundTimerViewController.swift
//  BJJTV
//
//  Created by BenRussell on 5/18/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import UIKit
import AVFoundation

class BJJTVRoundTimerViewController: UIViewController, BJJTVTimerControllerDelegate {
    
    @IBOutlet weak var restTimerlabel: UILabel!
    @IBOutlet weak var restTimerSlider: UISlider!
    @IBOutlet weak var roundTimerLabel: UILabel!
    @IBOutlet weak var roundTimerSlider: UISlider!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!

    var restTime:Int?
    var roundTime:Int?
    var timerRunning:Bool?
    var playSound:Int?
    var timerSwitch = 0
    var timerController:BJJTVTimerController?
    var audioPlayer = AVAudioPlayer()
    var soundTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countdownView.isHidden = true
        timerController = BJJTVTimerController()
        timerController?.delegate = self
        restTime = 2
        roundTime = 10
        timerRunning = false
        // preferredInterfaceOrientationForPresentation = .portrait
        UIApplication.shared.isIdleTimerDisabled = true
        
        do
        {
            let audioPath = Bundle.main.path(forResource: "bell", ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
        }
        catch
        {
            //ERROR
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timerController?.stopTime()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    func timeChanged() {
        countdownLabel.text = stringFromTimeInterval(interval: Double((timerController?.seconds)!))
        if timerController?.seconds == 0 && timerRunning == false {
            timerRunning = true
            startRoundTimer()
        } else if timerController?.seconds == 0 {
            if timerSwitch == 1 {
                do
                {
                    let audioPath = Bundle.main.path(forResource: "bell", ofType: ".mp3")
                    try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
                }
                catch
                {
                    //ERROR
                }
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                // playSound = 0
                // soundTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(BJJTVRoundTimerViewController.shutOfSound), userInfo: nil, repeats: true)
            }
            startRoundTimer()
        } else if timerController?.seconds == 30 && timerSwitch == 1 {
            countdownLabel.backgroundColor = UIColor.red
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } else if timerController?.seconds == 28 && timerSwitch == 1 {
            // audioPlayer.pause()
        }
    }
    
    func startInitialTimer() {
        // run initial 5 second countdown
        timerController?.seconds = 5
        countdownLabel.text = "00:05"
        timerController?.startTimer()
    }
    
    func startRoundTimer() {
        if timerSwitch == 0 {
            // round time
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            countdownLabel.backgroundColor = UIColor.yellow
            countdownLabel.textColor = UIColor.black
            timerController?.stopTime()
            timerController?.seconds = Int(roundTimerSlider.value) * 60
            countdownLabel.text = stringFromTimeInterval(interval: Double((timerController?.seconds)!))
            timerController?.startTimer()
            timerSwitch = 1
        } else {
            // rest time
            timerController?.stopTime()
            timerController?.seconds = Int(restTimerSlider.value) * 60
            if timerController?.seconds == 0  {
                timerSwitch = 0
                startRoundTimer()
            } else {
                countdownLabel.backgroundColor = UIColor.green
                countdownLabel.textColor = UIColor.darkGray
                countdownLabel.text = stringFromTimeInterval(interval: Double((timerController?.seconds)!))
                timerController?.startTimer()
                timerSwitch = 0
            }
        }
    }
    
    func stopTimer() {
        countdownView.isHidden = true
        timerController?.stopTime()
        timerSwitch = 0
    }
    
    func shutOfSound() {
        playSound = playSound! + 1
        if playSound == 5 {
            audioPlayer.pause()
            soundTimer?.invalidate()
        }
        
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func restTimeSliderMoved(_ sender: UISlider) {
        restTime = Int(sender.value)
        restTimerlabel.text = String(describing: restTime!)
    }
    
    @IBAction func roundTimeSliderMoved(_ sender: UISlider) {
        roundTime = Int(sender.value)
        roundTimerLabel.text = String(describing: roundTime!)
    }
    @IBAction func startStopButtonPressed(_ sender: UIButton) {
        if startButton.currentTitle == "GO" {
            // TODO: Fade in countdownView
            countdownLabel.backgroundColor = UIColor.black
            countdownLabel.textColor = UIColor.white
            countdownView.isHidden = false
            
            startInitialTimer()
            startButton.setTitle("STOP", for: .normal)
            startButton.setTitleColor(UIColor.red, for: .normal)
        } else {
            startButton.setTitle("GO", for: .normal)
            startButton.setTitleColor(UIColor.init(colorLiteralRed: 45.0/255.0, green: 138.0/255.0, blue: 32.0/255.0, alpha: 1.0), for: .normal)
            stopTimer()
        }
    }
}
