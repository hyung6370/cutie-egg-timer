//
//  ViewController.swift
//  EggTimer
//
//  Created by KIM Hyung Jun on 2023/07/25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var softButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    var player: AVAudioPlayer?
    
    let eggTimes = ["반숙": 450, "반반": 570, "완숙": 720]
    
    var timer = Timer()
    var totalTime = 0
    var secondsPassed = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }


    @IBAction func buttonTapped(_ sender: UIButton) {
        timer.invalidate()
        let hardness = sender.currentTitle!
        totalTime = eggTimes[hardness]!
        
        progressBar.progress = 0.0
        secondsPassed = 0
        titleLabel.text = hardness
        displayTimer(time: totalTime)
    }
    
    func displayTimer(time: Int) {
        let minutes: Int = time / 60
        let seconds: Int = time % 60
        
        let formattedTime = String(format: "%02d : %02d", minutes, seconds)
        timerLabel.text = formattedTime
        
        if minutes == 1 && seconds == 0 {
            oneMinuteMusic()
        }
    }
    
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        timer.invalidate()
        progressBar.progress = 0.0
        secondsPassed = 0
        titleLabel.text = "조리 중.." // 바로 표시될 메시지
        displayTimer(time: totalTime) // 타이머 레이블을 즉시 업데이트
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        timer.invalidate()
        progressBar.progress = 0.0
        secondsPassed = 0
        titleLabel.text = "삶을 방식을 선택해주세요!"
        timerLabel.text = "00 : 00"
    }
    
    @objc func updateTimer() {
        if secondsPassed < totalTime {
            secondsPassed += 1
            progressBar.progress = Float(secondsPassed) / Float(totalTime)
            displayTimer(time: totalTime - secondsPassed)
            titleLabel.text = "조리 중.."
            
            if totalTime - secondsPassed == 60 {
                sendNotification()
            }
        }
        else {
            timer.invalidate()
            titleLabel.text = "조리 완료!"
            playSound(code: "C")
        }
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "EggTimer"
        content.body = "1분 남았습니다!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "EggTimerNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 요청 추가 오류: \(error)")
            }
        }
    }
    
    func configureUI() {
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = UIColor.white.cgColor
        resetButton.layer.cornerRadius = 7
        resetButton.clipsToBounds = true
        
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor.white.cgColor
        startButton.layer.cornerRadius = 7
        startButton.clipsToBounds = true
        
        softButton.layer.borderWidth = 1
        softButton.layer.borderColor = UIColor.orange.cgColor
        softButton.layer.cornerRadius = 10
        softButton.clipsToBounds = true
        
        mediumButton.layer.borderWidth = 1
        mediumButton.layer.borderColor = UIColor.orange.cgColor
        mediumButton.layer.cornerRadius = 10
        mediumButton.clipsToBounds = true
        
        hardButton.layer.borderWidth = 1
        hardButton.layer.borderColor = UIColor.orange.cgColor
        hardButton.layer.cornerRadius = 10
        hardButton.clipsToBounds = true
    }
    
    func oneMinuteMusic() {
        playSound(code: "G")
    }
    
    func playSound(code: String) {
        guard let url = Bundle.main.url(forResource: code, withExtension: "wav") else {
            return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}


