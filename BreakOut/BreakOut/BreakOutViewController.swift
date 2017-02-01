//
//  BreakOutViewController.swift
//  BreakOut
//
//  Created by Wilko Zonnenberg on 30-11-16.
//  Copyright © 2016 Wilko Zonnenberg. All rights reserved.
//

import UIKit
import AVFoundation

class BreakOutViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameView: BezierPathsView!
    private var gameStarted = false
    private var highScoreArray: [Int:[Int:String]]?
    private let breakOutBehavior = BreakOutBehavior()
    private var remainingLives = 0
    private var amountOfBricks = 0
    private var gamePaused = false
    private var frozenBreakoutBalls = [BreakOutBall]()
    private var livesViews = [UIImageView]()
    private var breakoutBalls: [BreakOutBall] = []
    private var pauseView: UIView?
    private var paddleView: UIView?
    private var firstHitFromPaddle = true
    private var blocks = [String:UIView]()
    
    struct Sounds {
        static let winner = ["winner","wav", 4.0] as [Any]
        static let loser = ["loser", "wav", 2.24] as [Any]
        static let pong = ["pong", "wav", 0.17] as [Any]
        static let startGame = ["startgame", "wav", 4.00] as [Any]
        static let boundsPong = ["boundspong", "wav", 0.10] as [Any]
        static let ballLost = ["balllost", "wav", 0.96] as [Any]
    }
    
    struct Boundarys {
        static let Paddle = "Paddle"
        static let Block = "Block"
    }
    
    private var score = 0 {
        didSet{
            scoreLabel.text = String(score)
        }
    }
    
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedAnimator.delegate = self
        return lazilyCreatedAnimator
    }()
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {

    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breakOutBehavior.collider.collisionDelegate = self
        animator.addBehavior(breakOutBehavior)
        createStartScreen()

        
        NotificationCenter.default.addObserver(self, selector: #selector(BreakOutViewController.resetGame), name: NSNotification.Name(rawValue: SettingsHelper.SettingsObserver), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if gamePaused, gameStarted{
            restoreGame()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pauseGame()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        resetGame()

        
    }
    
    // MARK: - Play/Pause
    private func pauseGame(){
        gamePaused = true
        for breakOutBall in breakoutBalls {
            breakOutBall.linearVelocity = breakOutBehavior.ballBehavior.linearVelocity(for: breakOutBall)
            frozenBreakoutBalls.append(breakOutBall)
//            breakOutBall.removeFromSuperview()
            breakOutBehavior.removeBall(ball: breakOutBall)
        }
        breakoutBalls.removeAll()
    }
    
    
    @objc private func resetGame(){
        gameStarted = false
        clearGameView()
        createStartScreen()
    }
    
    private func createStartScreen(){
        pauseView?.removeFromSuperview()
        pauseView = nil
        pauseView = UIView(frame: gameView.frame)
        gameView.addSubview(pauseView!)
        let imageView = UIImageView(image: #imageLiteral(resourceName: "start-button"))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.center = gameView.center
        imageView.backgroundColor = UIColor.black
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.maxX, height: self.view.bounds.maxY)
        pauseView?.addSubview(imageView)
    }
    
    private func restoreGame() {
        gamePaused = false
        if frozenBreakoutBalls.count > 0 {
            for breakOutBall in frozenBreakoutBalls {
                breakoutBalls.append(breakOutBall)
                breakOutBehavior.addBall(ball: breakOutBall)
                breakOutBehavior.restorePushBall(ball: breakOutBall)
            }
            frozenBreakoutBalls.removeAll()
        }
    }
    
    private func startGame() {
        pauseView?.removeFromSuperview()
        pauseView = nil
        gameStarted = true
        remainingLives = SettingsHelper.getLives()
        playSound(soundName: Sounds.startGame[0] as! String, extensionName: Sounds.startGame[1] as! String, duration: Sounds.startGame[2] as! TimeInterval)
        score = 0
        drawBlocks()
        drawPaddle()
        drawBreakOutBall()
        drawLives()
        gameView.bringSubview(toFront: scoreLabel)
    }
    
    private func clearGameView() {
        if breakoutBalls.count > 0 {
            for breakoutBall in breakoutBalls {
                breakOutBehavior.removeBall(ball: breakoutBall)
            }
            breakoutBalls.removeAll()
        }
        if paddleView != nil {
            breakOutBehavior.removeBarrier(named: Boundarys.Paddle)
            paddleView?.removeFromSuperview()
            paddleView = nil
        }
        for (identifier, block) in blocks {
            breakOutBehavior.removeBarrier(named: identifier)
            block.removeFromSuperview()
        }
        blocks.removeAll()
    }
    
    private func gameOver(win: Bool){
        if gameStarted {
            clearGameView()
            if pauseView != nil {
                pauseView?.removeFromSuperview()
                pauseView = nil
            }
            pauseView = UIView(frame: gameView.frame)
            gameView.addSubview(pauseView!)
            
            var imageView : UIImageView?
            if win {
                imageView = UIImageView(image: #imageLiteral(resourceName: "winner"))
                playSound(soundName: Sounds.winner[0] as! String, extensionName: Sounds.winner[1] as! String, duration: Sounds.winner[2] as! TimeInterval)
                checkHighScore()
            } else {
                imageView = UIImageView(image: #imageLiteral(resourceName: "failed"))
                playSound(soundName: Sounds.loser[0] as! String , extensionName: Sounds.loser[1] as! String, duration: Sounds.loser[2] as! TimeInterval)
            }
            imageView?.contentMode = UIViewContentMode.scaleAspectFit
            imageView?.center = gameView.center
            imageView?.backgroundColor = UIColor.black
            imageView?.frame = CGRect(x: 0, y: 0, width: gameView.bounds.maxX, height: self.view.bounds.maxY)
            pauseView?.addSubview(imageView!)
            
            let restartLabel = UILabel(frame: CGRect(x: 0, y: gameView.bounds.maxY/4*2, width: self.view.bounds.maxX, height: gameView.bounds.maxY-gameView.bounds.maxY/3))
            restartLabel.text = "Score: \(score) \n\n Press the screen to restart."
            restartLabel.numberOfLines = 3
            restartLabel.font = UIFont.preferredFont(forTextStyle: .body)
            restartLabel.textColor = UIColor.white
            restartLabel.textAlignment = .center
            pauseView?.addSubview(restartLabel)
            gameStarted = false
        }
    }
    
    // MARK: - Score
    private func checkHighScore(){
        let highScoreArray = SettingsHelper.getHighScore()
        var place = 0
        for (_, highScoreNotation) in highScoreArray {
            for (highScore, _) in highScoreNotation {
                if score < highScore {
                    place += 1
                }
            }
            
        }
        if place < 9 {
            self.highScoreArray = highScoreArray
            
            var highScoreNameTextField: UITextField?
            let alertController = UIAlertController(title: "New HighScore!", message: "You gained place \(place+1) in the highscores!", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
                self.addHighScore(name: (highScoreNameTextField?.text)!, place: place)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                alertController.dismiss(animated: true, completion: {
//                    print("alert dismissed")
                })
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            alertController.addTextField { (textField) -> Void in
                // Enter the textfiled customization code here.
                highScoreNameTextField = textField
                highScoreNameTextField?.placeholder = "Enter your name."
            }
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func addHighScore(name: String, place: Int) {
        if (highScoreArray?.count)! < 19 {
            var highScorePlace = 19
            while highScorePlace >= place {
                    highScoreArray?[highScorePlace+1]?.removeAll()
                    highScoreArray?[highScorePlace+1] = highScoreArray?[highScorePlace]
                    highScorePlace -= 1
            }
        }
        if let noHighScore = highScoreArray?[0], noHighScore[0] != nil {
            highScoreArray?.removeAll()
        }
        highScoreArray?[place]?.removeAll()
        highScoreArray?[place] = [score:name]
        SettingsHelper.setHighScore(highScores: highScoreArray!)
    }
    
    private func updateScore(scoreToAdd: Int) {
        if breakoutBalls.count > 1 {
            score += scoreToAdd + breakoutBalls.count*2
        } else {
            score += scoreToAdd
        }
    }
    
    // MARK: - Lives
    private func drawLives() {
        for imageView in livesViews {
            imageView.removeFromSuperview()
        }
        livesViews.removeAll()
        var i = 1
        let sections = Double(remainingLives)
        var height = Double(gameView.frame.size.height)/2/sections
        if height > 40 {
            height = 40
        }
        for _ in 0..<remainingLives {
            let y = Double(scoreLabel.frame.maxY) - height*Double(i)
            let frame = CGRect(x: 8, y: y, width: height, height: height)
            let imageView = UIImageView(frame: frame)
            imageView.contentMode = .scaleAspectFit
            imageView.image = #imageLiteral(resourceName: "Lives")
            gameView.addSubview(imageView)
            livesViews.append(imageView)
            i += 1
        }
    }
    
    private func removeLifes(amountOfLivesToRemove: Int) {
        for _ in 0..<amountOfLivesToRemove {
            let imageView = livesViews.last
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                imageView?.frame = CGRect(x: (imageView?.frame.midX)!, y: (imageView?.frame.midY)!, width: 1, height: 1)
            }, completion: { (completion) in
                if completion {
                    self.livesViews.last?.removeFromSuperview()
                    self.livesViews.removeLast()
//                    print("live removed")
                    
                } else {
//                    print("live not removed, something went wrong")
                }
            })
            
        }
        remainingLives -= amountOfLivesToRemove
    }
    
   // MARK: - BreakOutBall
    private func drawBreakOutBall(){
        for ball in breakoutBalls {
            breakOutBehavior.removeBall(ball: ball)
            ball.removeFromSuperview()
        }
        breakoutBalls.removeAll()
        var i = 1
        let balls = SettingsHelper.getBalls()
        let paddleMinX = Double((paddleView?.frame.minX)!)
        let sections = Double(balls+1)
        for _ in 0..<balls {
            let x = paddleMinX+(Double((paddleView?.bounds.width)!)/sections*Double(i))
            let frame = CGRect(x: x, y: Double((paddleView?.frame.origin.y)!-21), width: 20, height: 20)
            let breakoutBall = BreakOutBall(frame: frame)
            breakOutBehavior.addBall(ball: breakoutBall)
            firstHitFromPaddle = true
            breakoutBalls.append(breakoutBall)
            i += 1
        }
    }
    
    
    // MARK: - Gestures
    @IBAction func grabBlock(_ sender: UIGestureRecognizer) {
        let gesturePoint = sender.location(in: gameView)
        switch sender.state {
        case .began:
            setPaddleToGesturePoint(gesturePoint: gesturePoint)
            break
        case .changed:
            setPaddleToGesturePoint(gesturePoint: gesturePoint)
            break
        default:
            break
        }
        
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        if !gameStarted {
            startGame()
        } else if firstHitFromPaddle, breakoutBalls.count > 0 {
            for breakoutBall in breakoutBalls {
                breakOutBehavior.firstPushBall(ball: breakoutBall)
            }
            firstHitFromPaddle = false
        } else {
            if breakoutBalls.count > 0 {
                for breakoutBall in breakoutBalls {
                    breakOutBehavior.pushBall(ball: breakoutBall)
                }
            }
        }
        
    }
    
    // MARK: - Paddle
    private func drawPaddle(){
        if paddleView == nil {
            var paddleWidth = view.bounds.size.width.multiplied(by: CGFloat(SettingsHelper.getPaddleWidth()))
            var x = view.bounds.midX - paddleWidth/2
            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
                paddleWidth += 20
                x -= 10
            }
            let frame = CGRect(x: x, y: view.bounds.maxY - view.bounds.maxY/5, width: paddleWidth, height: paddleWidth/8)
            paddleView = UIView(frame: frame)
            paddleView?.layer.cornerRadius = (paddleView?.frame.size.height)!/2
            paddleView?.layer.borderColor = UIColor.black.cgColor
            paddleView?.layer.borderWidth = 2
            paddleView?.backgroundColor = UIColor.random
            gameView.addSubview(paddleView!)
            setPaddleBoundary()
        }
    }
    
    private func setPaddleToGesturePoint(gesturePoint: CGPoint){
        if paddleView != nil {
            var frame = paddleView?.frame
            let newOriginX = gesturePoint.x - (frame?.size.width.divided(by: 2))!
            if newOriginX < self.gameView.bounds.minX {
                frame?.origin.x = self.gameView.bounds.minX
            } else if newOriginX + (paddleView?.frame.size.width)! > self.gameView.bounds.maxX {
                frame?.origin.x = self.gameView.bounds.maxX - (paddleView?.frame.size.width)!
            } else {
                frame?.origin.x = newOriginX
            }
            paddleView?.frame = frame!
            setPaddleBoundary()
        }
    }
    
    
    private func setPaddleBoundary() {
        if paddleView != nil {
            UIGraphicsBeginImageContextWithOptions(gameView.frame.size, true, 1)
            let paddleBoundary = UIBezierPath(ovalIn: (paddleView?.frame)!)
            breakOutBehavior.addBarrier(path: paddleBoundary, named: Boundarys.Paddle)
        }
    }
    
    // MARK: - Blocks
    func drawBlocks(){
        let size = self.view.bounds.width.divided(by: CGFloat(SettingsHelper.getColumns()))
        let rows = SettingsHelper.getRows()
        var height = CGFloat(Int(gameView.frame.size.height)/2/rows)
        if height > size/2 {
            height = size/2
        }
        let blockSize = CGSize(width: size, height: height)
        var row = 0
        while row < SettingsHelper.getRows(){
            var colomn = 0
            while colomn < SettingsHelper.getColumns() {
                let frame = CGRect(x: blockSize.width.multiplied(by: CGFloat(colomn)), y: blockSize.height.multiplied(by: CGFloat(row)), width: blockSize.width, height: blockSize.height)
                let blockView = UIView(frame: frame)
                blockView.backgroundColor = UIColor.random
                blockView.layer.shadowOffset = CGSize(width: 10,height: 10)
                blockView.layer.cornerRadius = blockView.frame.size.height/6
                blockView.layer.borderWidth = 1
                blockView.layer.borderColor = UIColor.black.cgColor
                blockView.setNeedsDisplay()
                let blockBoundary = UIBezierPath(rect: blockView.frame)
                let blockIdentifier = Boundarys.Block + "\(row)-\(colomn)"
                blocks[blockIdentifier] = blockView
                breakOutBehavior.addBarrier(path: blockBoundary, named: blockIdentifier)
                gameView.addSubview(blockView)
                colomn += 1
            }
            row += 1
        }
    }
    
    // MARK: - Collision
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if let collisionIdentifier = identifier as? String {
            if collisionIdentifier == Boundarys.Paddle {
                playSound(soundName: Sounds.pong[0] as! String, extensionName: Sounds.pong[1] as! String, duration: Sounds.pong[2] as! TimeInterval)
            } else if collisionIdentifier.contains( Boundarys.Block) {
                playSound(soundName: Sounds.pong[0] as! String, extensionName: Sounds.pong[1] as! String, duration: Sounds.pong[2] as! TimeInterval)
                if let block = blocks[collisionIdentifier] {
                    breakOutBehavior.removeBarrier(named: collisionIdentifier)
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        block.frame = CGRect(x: block.frame.midX, y: block.frame.midY, width: 1, height: 1)
                    }, completion: { _ in
                        block.removeFromSuperview()
                        self.blocks.removeValue(forKey: identifier as! String)
                        self.updateScore(scoreToAdd: 10)
                        if self.blocks.count == 0{
                            self.gameOver(win: true)
                        }
                        block.layer.removeAllAnimations()
                    })

                }
            }
        } else {
            var ballLost = false
            for breakoutBall in breakoutBalls {
                if paddleView != nil, Double(breakoutBall.frame.origin.y) > Double((paddleView?.frame.origin.y)!) {
                    removeLifes(amountOfLivesToRemove: 1)
                    ballLost = true
                    breakOutBehavior.removeBall(ball: breakoutBall)
                    breakoutBall.removeFromSuperview()
                    breakoutBalls.remove(at: breakoutBalls.index(of: breakoutBall)!)
                    playSound(soundName: Sounds.ballLost[0] as! String, extensionName: Sounds.ballLost[1] as! String, duration: Sounds.ballLost[2] as! TimeInterval )
                    if remainingLives <= 0 {
                        gameOver(win: false)
//                        print("You DIED NOOOOOOB")
                    } else if breakoutBalls.count == 0 {
                        drawBreakOutBall()
                    }
                    
                }
            }
            if !ballLost {
                playSound(soundName: Sounds.boundsPong[0] as! String, extensionName: Sounds.boundsPong[1] as! String, duration: (Sounds.boundsPong[2] as? TimeInterval)!)
            }
        }
    }

    // MARK: - Sounds
    func playSound(soundName: String, extensionName: String, duration: Double) {
        if SettingsHelper.getSound(){
            DispatchQueue.global(qos: .background).async {
                let url = Bundle.main.url(forResource: soundName, withExtension: extensionName)!
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    DispatchQueue.main.sync {
                        _ = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(BreakOutViewController.stopSound(timer:)), userInfo: player, repeats: false)
                    }
                    player.prepareToPlay()
                    player.play()
                
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @objc func stopSound(timer: Timer) {
        var player = timer.userInfo as? AVAudioPlayer
        player?.stop()
        timer.invalidate()
        player = nil
        // http://stackoverflow.com/questions/40389308/strange-aqdefaultdevice-logging
        
    }
}

private extension CGFloat {
    static func random(_ max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

private extension UIColor {
    class var random: UIColor{
        switch arc4random()%5 {
        case 0: return UIColor.green
        case 1: return UIColor.blue
        case 2: return UIColor.orange
        case 3: return UIColor.red
        case 4: return UIColor.purple
        default: return UIColor.black
        }
    }
}
