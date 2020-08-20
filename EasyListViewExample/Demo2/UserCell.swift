//
//  UserCell.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/17.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

class UserCell: UIView {
    
    var avatarView: UIImageView!
    var nameLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .white
        
        avatarView = UIImageView()
        avatarView.contentMode = .scaleAspectFit
        nameLabel = UILabel()
        
        let separator = UIView()
        separator.backgroundColor = #colorLiteral(red: 0.8979505897, green: 0.8981012702, blue: 0.8979307413, alpha: 1)
        
        subviews(avatarView, nameLabel, separator)
        height(66)
        layout(
            5,
            |-16-avatarView,
            5,
            |-16-separator.height(1 / UIScreen.main.scale)|,
            0
        )
        avatarView.Width == avatarView.Height
        nameLabel.Top == avatarView.Top
        nameLabel.Leading == avatarView.Trailing + 5
    }
    
    func set(name: String?, avatar: UIImage?) {
        avatarView.image = avatar
        nameLabel.text = name
    }
}
