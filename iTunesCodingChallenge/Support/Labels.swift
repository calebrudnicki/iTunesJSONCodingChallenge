//
//  Labels.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 7/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import UIKit

class HeaderLabel: UILabel {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .black
    }
    
}

class BodyLabel: UILabel {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        numberOfLines = 0
        textColor = .red
    }
    
}
