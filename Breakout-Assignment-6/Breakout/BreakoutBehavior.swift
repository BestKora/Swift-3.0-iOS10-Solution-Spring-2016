//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Tatiana Kornilova on 9/4/15.
//  Copyright (c) 2015 Tatiana Kornilova. All rights reserved.
//

import UIKit

// MARK: - CLASS BreakoutBehavior

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    var hitBreak : ((_ behavior: UICollisionBehavior, _ ball: BallView,
                                                _ brickIndex: Int)-> ())?
    var leftPlayingField : ((_ ball: BallView)-> ())?
    
    // MARK: - GRAVITY
    
    var gravity = UIGravityBehavior()
    var gravityMagnitudeModifier:CGFloat = 1.0 {
        didSet{
            gravity.magnitude = gravityMagnitudeModifier
        }
    }
    
    // MARK: - COLLIDER
    
    private lazy var collider: UICollisionBehavior = {
        let сollider = UICollisionBehavior()
        сollider.translatesReferenceBoundsIntoBoundary = false
        сollider.collisionDelegate = self
        сollider.action = { [unowned self] in
            
            for ball in self.balls {
                if !self.dynamicAnimator!.referenceView!.bounds.intersects(ball.frame){
                    self.leftPlayingField?( ball as BallView)
                }
                
                self.ballBehavior.limitLinearVelocity(min: Constants.Ball.MinVelocity,
                                                      max: Constants.Ball.MaxVelocity,
                                                      forItem: ball as BallView)
            }
        }
        return сollider
        }()
    
    // MARK: - BALLBehavior
    
   private lazy var ballBehavior: UIDynamicItemBehavior = {
        let ballBehavior = UIDynamicItemBehavior()
        ballBehavior.allowsRotation = false
        ballBehavior.elasticity = 1.0
        ballBehavior.friction = 0.0
        ballBehavior.resistance = 0.0
        return ballBehavior
        }()
    
    
    var balls: [BallView] {
        get { return collider.items.filter{$0 is BallView}.map{$0 as! BallView} }
    }
    
    // MARK: - INIT
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
    }
    
    // MARK: - BOUNDARIES
    
    func addBoundary(path: UIBezierPath, named identifier: NSCopying) {
        removeBoundary(identifier: identifier)
        collider.addBoundary(withIdentifier: identifier, for: path)
    }
    
    func removeBoundary (identifier: NSCopying) {
        collider.removeBoundary(withIdentifier: identifier)
    }
    
     // MARK: - COLLISION BEHAVIOR Delegate
    
    func collisionBehavior(_ behavior: UICollisionBehavior,
                 beganContactFor item: UIDynamicItem,
    withBoundaryIdentifier boundaryId: NSCopying?,
                                 at p: CGPoint) {
        
        if let brickIndex = boundaryId as? Int {
            if let ball = item as? BallView {
                  self.hitBreak?(behavior, ball, brickIndex)
              }
        }
    }
    
    // MARK: - BALL
    
    func addBall(ball: UIView) {
        
        self.dynamicAnimator?.referenceView?.addSubview(ball)
        gravity.addItem(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(ball: UIView) {
        gravity.removeItem(ball)
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
        ball.removeFromSuperview()
    }
    
    func removeAllBalls(){
        for ball in balls {
            removeBall(ball: ball)
        }
    }
    
    //  останавливаем мячик
    func stopBall(ball: UIView) -> CGPoint {
        let linVeloc = ballBehavior.linearVelocity(for: ball)
        ballBehavior.addLinearVelocity(CGPoint(x: -linVeloc.x, y: -linVeloc.y),
                                                             for: ball)
        return linVeloc
    }
    
    //  запускаем мячик после остановки
    func reStartBall(ball: UIView, velocity: CGPoint) {
        ballBehavior.addLinearVelocity(velocity, for: ball)
    }
    
    //запуск мячика c помощью push
    func launchBall(ball: UIView, magnitude: CGFloat) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: .instantaneous)
        pushBehavior.magnitude = magnitude
        
        let angle = CGFloat(1.25 * M_PI +
                     (0.5 * M_PI) * (Double(arc4random()) / Double(UINT32_MAX)))
        pushBehavior.angle = angle
        
        pushBehavior.action = { [weak pushBehavior] in
            if !pushBehavior!.active { self.removeChildBehavior(pushBehavior!) }
        }
        
        addChildBehavior(pushBehavior)
    }
    
    func linearVelocity (item: UIDynamicItem) -> CGPoint {
        return ballBehavior.linearVelocity (for: item)}
    
    // MARK: - CONSTANTS

    
   private struct Constants {
        struct Ball {
            static let MinVelocity = CGFloat(100.0)
            static let MaxVelocity = CGFloat(1400.0)
        }
    }
}

