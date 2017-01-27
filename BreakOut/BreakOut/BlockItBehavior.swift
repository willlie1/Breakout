//
//  BreakOutBehavior.swift
//  BreakOut
//
//  Created by Wilko Zonnenberg on 30-11-16.
//  Copyright © 2016 Wilko Zonnenberg. All rights reserved.
//

import UIKit

class BreakOutBehavior: UIDynamicBehavior {
    
    
    lazy var gravity: UIGravityBehavior = {
        let lazilyCreatedGravityBehavior = UIGravityBehavior()
        
        lazilyCreatedGravityBehavior.magnitude = 0
        lazilyCreatedGravityBehavior.gravityDirection = CGVector(dx: 0.0, dy: 0.0)
        return lazilyCreatedGravityBehavior
    }()
    
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = true
        return lazilyCreatedCollider
    }()
    
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
        lazilyCreatedBallBehavior.allowsRotation = true
        lazilyCreatedBallBehavior.elasticity = 1
        lazilyCreatedBallBehavior.friction = 0
        lazilyCreatedBallBehavior.resistance = 0
        return lazilyCreatedBallBehavior
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
        
    }
    
    // MARK: - Barrier
    func addBarrier(path: UIBezierPath, named name: String){
        removeBarrier(named: name)
        collider.addBoundary(withIdentifier: name as NSCopying, for: path)
    }

    func removeBarrier( named name: String ) {
        collider.removeBoundary(withIdentifier: name as NSCopying)
    }
    
    // MARK: - Ball
    func addBall(ball: BreakOutBall){
        self.ballBehavior.dynamicAnimator?.referenceView?.addSubview(ball)
        gravity.addItem(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(ball: BreakOutBall) {
        gravity.removeItem(ball)
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
        ball.removeFromSuperview()
    }
    
    // MARK: - Push
    func firstPushBall(ball: BreakOutBall){
        let push = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.instantaneous)
        push.angle = randomBetweenNumbers(firstNum: 4, secondNum: 6)
        push.magnitude = CGFloat(SettingsHelper.getBallSpeed())
        push.active = true
        push.action = { [unowned push] in
            push.removeItem(ball)
            push.dynamicAnimator?.removeBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func pushBall(ball: BreakOutBall){
        let push = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.instantaneous)
        let linearVelocity = ballBehavior.linearVelocity(for: ball)
        let currentAngle = Double(atan2(linearVelocity.y, linearVelocity.x))
        let oppositeAngle = CGFloat((currentAngle + M_PI).truncatingRemainder(dividingBy: (2 * M_PI)))
        let lower = oppositeAngle - CGFloat((30 * M_PI)/180)
        let upper = oppositeAngle + CGFloat((30 * M_PI)/180)
        push.magnitude = CGFloat(SettingsHelper.getBallSpeed()*2)
        push.angle = randomBetweenNumbers(firstNum: lower, secondNum: upper)

        push.action = { [unowned push] in
            push.removeItem(ball)
            self.ballBehavior.dynamicAnimator?.removeBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func restorePushBall(ball: BreakOutBall) {
        let push = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.instantaneous)
        let linearVelocity = ball.linearVelocity
        let currentAngle = Double(atan2(linearVelocity.y, linearVelocity.x))
        push.magnitude = CGFloat(SettingsHelper.getBallSpeed())
        push.angle = CGFloat(currentAngle)
        push.active = true
        push.action = { [unowned push] in
            push.removeItem(ball)
            push.dynamicAnimator?.removeBehavior(push)
        }
        addChildBehavior(push)
    }
    
//    func pushBallAfterCollision(ball: UIView){
//        let push = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.instantaneous)
//        //        push.setAngle(90, magnitude: 0.2)
//        let linearVelocity = ballBehavior.linearVelocity(for: ball)
//        push.magnitude = 0.09
//        let currentAngle = Double(atan2(linearVelocity.y, linearVelocity.x))
//        push.angle = CGFloat(currentAngle)
//
//        push.action = { [unowned push] in
//            push.removeItem(ball)
//            self.ballBehavior.dynamicAnimator?.removeBehavior(push)
//        }
//        addChildBehavior(push)
//    }
    
    // MARK: - Utility
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
}
