//
//  ViewController.swift
//  Tesellation
//
//  Created by Oleksandr Glagoliev on 3/2/20.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let v = VoronoiView(frame: view.bounds)
        v.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(v)
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: view.topAnchor),
            v.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            v.leftAnchor.constraint(equalTo: view.leftAnchor),
            v.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
    }
}
