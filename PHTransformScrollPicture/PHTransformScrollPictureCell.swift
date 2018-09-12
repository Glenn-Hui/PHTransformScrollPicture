//
//  PHTransformScrollPictureCell.swift
//  ScrollPicture
//
//  Created by  on 2018/9/11.
//  Copyright © 2018年 . All rights reserved.
//

import UIKit

class PHTransformScrollPictureCell: UICollectionViewCell {
    lazy var titleLabel:UILabel = UILabel(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
    lazy var picture:UIImageView = {()->UIImageView in
        let p = UIImageView()
        p.contentMode = .scaleAspectFill
        p.clipsToBounds = true
        return p
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(picture)
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        picture.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([NSLayoutConstraint(item: picture, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0),NSLayoutConstraint(item: picture, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0),NSLayoutConstraint(item: picture, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0),NSLayoutConstraint(item: picture, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)])
    }
    
}
