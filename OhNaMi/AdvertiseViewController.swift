//
//  AdvertiseViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 8. 11..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit

class AdvertiseViewController: UIViewController, UIAlertViewDelegate, GADRewardBasedVideoAdDelegate {
    
    enum GameState: NSInteger {
        case notStarted
        case playing
        case paused
        case ended
    }
    
    let gameOverReward = 1
    
    let gameLength = 10
    
    var coinCount = 0
    
    var adRequestInProgress = false
    
    var rewardBasedVideo: GADRewardBasedVideoAd?
    
    var timer: Timer?
    
    var counter = 10
    
    var gameState = GameState.notStarted
    
    var pauseDate: Date?
    
    var previousFireDate: Date?
    
    @IBOutlet weak var coinCountLabel: UILabel!
    @IBOutlet weak var gameText: UILabel!
    
    @IBOutlet weak var playAgainButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo?.delegate = self
        coinCountLabel.text = "Coins : \(self.coinCount)"
        
        startNewGame()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    fileprivate func startNewGame() {
        gameState = .playing
        counter = gameLength
        playAgainButton.isHidden = true
        
        if !adRequestInProgress && rewardBasedVideo?.isReady == false {
            rewardBasedVideo?.load(GADRequest(), withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
            adRequestInProgress = true
        }
        gameText.text = String(counter)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeFireMethod(_:)), userInfo: nil, repeats: true)
    }
    
    //앱이 백그라운드로 갔을때 처리
    func applicationDidEnterBackground(_ notification: Notification) {
        if gameState != .playing {
            return
        }
        gameState = .paused
        
        //정지 시간을 저장
        pauseDate = Date()
        previousFireDate = timer?.fireDate
        
        //앱이 백그라운드에서 실행시 광고 보는 시간이 가지 않게
        timer?.fireDate = Date.distantFuture
    }
    
    func applicationDidBecomeActive(_ notification : Notification) {
        
        if gameState != .paused {
            return
        }
        gameState = .playing
    }
    
    func timeFireMethod(_ timer: Timer) {
        counter -= 1
        if counter > 0 {
            gameText.text = String(counter)
        } else {
            endGame()
        }
    }
    
    fileprivate func earnCoins(_ coins: NSInteger) {
        coinCount += coins
        coinCountLabel.text = "Coins: \(self.coinCount)"
    }
    
    fileprivate func endGame() {
        gameState = .ended
        gameText.text = "Game over!"
        playAgainButton.isHidden = false
        timer?.invalidate()
        timer = nil
        earnCoins(gameOverReward)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playAgain(_ sender: Any) {
        if rewardBasedVideo?.isReady == true {
            rewardBasedVideo?.present(fromRootViewController: self)
        } else {
            let alert = UIAlertController(title: "Reward based video not ready", message: "The reward based video didn't finish loading or failed to load", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "done", style: .default, handler: { action in
                
                self.startNewGame()
                
            }))
                
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        adRequestInProgress = false
        print("Reward based video ad failed to load: \(error.localizedDescription)")
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        adRequestInProgress = false
        print("Reward based video ad is received.")
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        print("Reward receive with currency: \(reward.type), amount \(reward.amount).")
        earnCoins(NSInteger(reward.amount))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

}
