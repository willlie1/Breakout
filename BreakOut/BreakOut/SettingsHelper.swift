//
//  SettingsHelper.swift
//  BreakOut
//
//  Created by Wilko Zonnenberg on 20-12-16.
//  Copyright © 2016 Wilko Zonnenberg. All rights reserved.
//

import Foundation

class SettingsHelper {
    public static let SettingsObserver = "SettingsObserver"
    
    
    private static let rowsId = "RowsId"
    private static let columnsId = "ColumnsId"
    private static let ballsId = "BallsId"
    private static let livesId = "LivesId"
    private static let paddleWidthId = "PaddleWidthId"
    private static let ballSpeedId = "ballSpeedId"
    private static let soundId = "SoundId"
    private static let highScoreId = "HighScoreId"

    
    public static func notifyObservers(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SettingsHelper.SettingsObserver), object: nil)
    }
    
    // MARK: - Paddle
    public static func getPaddleWidth() -> Double {
        if let paddleWidth = getObject(key: paddleWidthId) as! Double? {
            return paddleWidth
        }
        return 0.3
    }
    
    public static func savePaddleWidth(paddleWith: Double) {
        storeObject(object: paddleWith, key: paddleWidthId)
    }
    
    // MARK: - Sound
    public static func getSound() -> Bool {
        if let paddleWidth = getObject(key: soundId) as! Bool? {
            return paddleWidth
        }
        return true
    }
    
    public static func saveSound(sound: Bool) {
        storeObject(object: sound, key: soundId)
    }
    
    // MARK: - HighScore
    public static func getHighScore() -> [Int:[Int:String]] {
        var highScores = [Int:[Int:String]]()
        var i = 0
        while i < 20 {
            var id = highScoreId
            id.append(String(i))
            if let highScoreString = getObject(key: id) as? String {
                let highScoreStringArray = highScoreString.components(separatedBy: ",")
                
                let highScore: [Int:String] = [Int(highScoreStringArray[0])!:highScoreStringArray[1] ]
                highScores[i] = highScore
                
                
                
                i += 1
            } else {
                break
            }
        }
        
        if highScores.count > 0 {
            return highScores
        }
        return [0:[0:"No High Scores"]]
    }
    
    public static func setHighScore(highScores: [Int:[Int:String]]) {
        for (key, highScore) in highScores {
            var id = highScoreId
            id.append(String(key))
            
            if let name = highScore.first?.value, let score = highScore.first?.key {
                let highScoreAsString = String(score) + "," + String(name)
                storeObject(object: highScoreAsString, key: id)
            }
        }
        
    }
    
    // MARK: - Rows
    public static func saveRows(rows: Int){
        storeObject(object: rows, key: rowsId)
    }
    
    public static func getRows() -> Int {
        if let rows = getObject(key: rowsId) as! Int? {
            return rows
        }
       return 4
    }
    
    // MARK: - Columns
    public static func saveColumns(columns: Int){
        storeObject(object: columns, key: columnsId)
    }
    
    public static func getColumns() -> Int {
        if let columns = getObject(key: columnsId) as! Int? {
            return columns
        }
        return 8
    }
    
    // MARK: - Balls
    public static func saveBalls(balls: Int){
        storeObject(object: balls, key: ballsId)
    }
    
    public static func getBalls() -> Int {
        if let balls = getObject(key: ballsId) as! Int? {
            return balls
        }
        return 1
    }
    
    public static func getBallSpeed() -> Double {
        if let ballSpeed = getObject(key: ballSpeedId) as! Double? {
            return ballSpeed
        }
        return 0.3
    }
    
    public static func saveBallSpeed(ballSpeed: Double) {
        storeObject(object: ballSpeed, key: ballSpeedId)
    }
    
    // MARK: - Lives
    public static func saveLives(lives: Int){
        storeObject(object: lives, key: livesId)
    }
    
    public static func getLives() -> Int {
        if let lives = getObject(key: livesId) as! Int? {
            return lives
        }
        return 1
    }
    
    // MARK: - Save/Store Object
    private static func getObject(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    private static func storeObject(object: Any, key: String) {
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
        notifyObservers()
    }
    
}
