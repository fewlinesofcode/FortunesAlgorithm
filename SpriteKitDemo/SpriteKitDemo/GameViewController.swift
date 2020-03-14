//
//  GameViewController.swift
//  SpriteKitDemo
//
//  Created by Oleksandr Glagoliev on 3/12/20.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func loadView() {
        self.view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let view = self.view as! SKView? {
            let scene = GameScene(size: view.bounds.size)
            scene.backgroundColor = .white
            scene.anchorPoint = CGPoint(x: 0, y: 0)
            scene.scaleMode = .aspectFill
            
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsDrawCount = true
            view.shouldCullNonVisibleNodes = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
