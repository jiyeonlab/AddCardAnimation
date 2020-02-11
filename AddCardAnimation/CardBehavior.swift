//
//  CardBehavior.swift
//  AddCardAnimation
//
//  Created by JiyeonKim on 06/10/2019.
//  Copyright © 2019 JiyeonKim. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {

    var snapPoint = CGPoint()
    
    lazy var collisionBehavior: UICollisionBehavior = {
       let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 0.99
        behavior.resistance = 0.1
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = (20*CGFloat.pi).arc4random
        
        push.magnitude = CGFloat(10.0) + CGFloat(15.0).arc4random
        push.action = { [unowned push, weak self] in
            //push.dynamicAnimator?.removeBehavior(push)
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    private func snap(_ item: UIDynamicItem){
        let snap = UISnapBehavior(item: item, snapTo: snapPoint)
        snap.damping = 1.0
        addChildBehavior(snap)
    }
    
    var setButton = UIButton()
    func addItem(_ item: UIDynamicItem){
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.collisionBehavior.removeItem(item)
            self.snap(item)
        }
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem){
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator){
        self.init()
        animator.addBehavior(self)
    }
}
