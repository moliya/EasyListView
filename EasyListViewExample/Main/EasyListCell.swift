//
//  EasyListCell.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/17.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

class EasyListCell: UIView {
    
    public var onTap: (() -> Void)?
    public let textLabel = UILabel()
    public var showIndicator = true {
        didSet {
            indicatorView.isHidden = !showIndicator
        }
    }
    
    private var normalColor: UIColor?
    private var highlightedColor = UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1)
    private var indicatorView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .white
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        
        textLabel.setContentHuggingPriority(.required, for: .horizontal)
        textLabel.font = .systemFont(ofSize: 16)
        textLabel.textColor = .darkText
        
        indicatorView.image = UIImage(named: "indicator")
        
        subviews(textLabel, indicatorView)
        layout(
            |-16-textLabel-""-indicatorView-16-|
        )
        textLabel.centerVertically()
    }
    
    @objc func tapAction() {
        onTap?()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        normalColor = backgroundColor
        backgroundColor = highlightedColor
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        backgroundColor = normalColor
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        backgroundColor = normalColor
    }
}
