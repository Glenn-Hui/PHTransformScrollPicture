//
//  PHTransform3DFlowLayout.swift
//  ScrollPicture
//
//  Created by  on 2018/9/11.
//  Copyright © 2018年 . All rights reserved.
//

import UIKit

class PHTransform3DFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let point = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        let targetRect = CGRect(x: point.x, y: 0, width: collectionView!.bounds.width, height: collectionView!.bounds.height)
        let attrArr = layoutAttributesForElements(in: targetRect) ?? []
        let centerX = targetRect.midX
        let targetItemAttr = attrArr.min{return fabsf(Float($0.center.x - centerX)) < fabsf(Float($1.center.x - centerX)) }
        
        if let attr = targetItemAttr{
            
            return CGPoint(x: attr.center.x - targetRect.width/2, y: point.y)
        }else{
            return point
        }
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let arr = super.layoutAttributesForElements(in: rect)?.compactMap({ (attr) -> UICollectionViewLayoutAttributes? in
            return (attr.copy() as! UICollectionViewLayoutAttributes)
        }) ?? []
        
        let visibleRect = CGRect(x: collectionView!.contentOffset.x, y: collectionView!.contentOffset.y, width: collectionView!.bounds.width, height: collectionView!.bounds.height)
        
        let centerX = visibleRect.midX
        let centerAttr = arr.min{return fabsf(Float($0.center.x - centerX)) < fabsf(Float($1.center.x - centerX)) }
        arr.forEach { (attr) in
            
            let distance = Float(attr.center.x - centerX)
            let scale = distance / Float(visibleRect.width)
            var transformIdentity = CATransform3DIdentity
            transformIdentity.m34 = 1/200
            let rotation = CATransform3DMakeRotation(CGFloat((Double.pi/4)*Double(scale)), 0, 1, 0)
            attr.transform3D = CATransform3DConcat(rotation,transformIdentity)
            attr.zIndex = centerAttr == attr ? 1 : 0
            
        }
        
        return arr
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        return true
    }
}
