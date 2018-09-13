//
//  PHTransformScrollPicture.swift
//  ScrollPicture
//
//  Created by  on 2018/9/11.
//  Copyright © 2018年 . All rights reserved.
//

import UIKit
import Kingfisher
@objc public protocol PHTransformScrollPictureDelegate:NSObjectProtocol {
    func phTransformScrollPictureItemWidth()->CGFloat
    func phTransformScrollPictureMinimumLineSpacing()->CGFloat
    @objc optional func phTransformScrollPictureItemChange(index:Int)
    @objc optional func phTransformScrollPictureSelect(index:Int)
}
private let SectionNum:Int = 11
public class PHTransformScrollPicture: UIView {
    public var delegate:PHTransformScrollPictureDelegate?
    public var hiddenPageControl:Bool = false{
        didSet{
            pageControl.isHidden = hiddenPageControl
        }
    }
    ///一张图片的时候是否循环
    public var onePactureCircle:Bool = false
    ///自动循环
    public var autoCircle:Bool = false
    ///间隔时长
    public var duration:Int = 5
    ///填充模式
    public var imgContentModel:UIViewContentMode = .scaleAspectFill
    
    
    var pictureUrls:[String] = []{
        didSet{
            pageControl.numberOfPages = pictureUrls.count
            collectionView.reloadData()
            
            if pictureUrls.count > 1 || (pictureUrls.count == 1 && onePactureCircle){
                addTimer()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {[weak self] in
                    
                    self?.scrollToItem(indexPath: IndexPath(item: 0, section: SectionNum/2+1), animate: false)
                    
                }
            }
        }
    }
    
    private lazy var collectionView:UICollectionView = {()->UICollectionView in
        let c = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        c.delegate = self
        c.dataSource = self
        c.backgroundColor = UIColor.white
        c.showsVerticalScrollIndicator = false
        c.showsHorizontalScrollIndicator = false
        c.clipsToBounds = false
        c.decelerationRate = 0
        c.register(PHTransformScrollPictureCell.self, forCellWithReuseIdentifier: "picture")
        return c
    }()
    private lazy var layout:PHTransformFlowLayout = {()->PHTransformFlowLayout in
        let l = PHTransformFlowLayout()
        l.scrollDirection = .horizontal
        return l
    }()
    private lazy var pageControl:UIPageControl = {()->UIPageControl in
        let p = UIPageControl()
        p.hidesForSinglePage = true
        p.pageIndicatorTintColor = UIColor(displayP3Red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1)
        p.currentPageIndicatorTintColor = UIColor(displayP3Red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1)
        return p
    }()
    private var timer:PHTimer?
    
    ///默认Item宽度
    private var defaultItemWidth:CGFloat = 0.0
    ///默认行间距
    private var defaultMinimumLineSpacing:CGFloat = 30.0
    ///滚动位置
    private var lastIndex:Int = 0
    private var lastIndexPath:IndexPath = IndexPath(item: 0, section: 0 )
    // MARK:外部调用
    func suspendTimer(){
        if (!autoCircle || pictureUrls.isEmpty){
            return
        }
        
        timer?.suspend()
    }
    func startTimer(){
        if (!autoCircle || pictureUrls.isEmpty){
            return
        }
        timer?.start()
    }
    // MARK: 私有方法
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI(){
        clipsToBounds = true
        addSubview(collectionView)
        addSubview(pageControl)
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        initialize()
        
        makeConstraint()
    
        
    }
    private func initialize(){
        defaultItemWidth = bounds.width/3
        
        let sectionInsetLeft:CGFloat = (delegate?.phTransformScrollPictureMinimumLineSpacing() ?? defaultMinimumLineSpacing)/2
        layout.sectionInset = UIEdgeInsetsMake(0, sectionInsetLeft, 0, sectionInsetLeft)
        
        let insetLeft = (bounds.width - (delegate?.phTransformScrollPictureItemWidth() ?? defaultItemWidth))/2 - sectionInsetLeft
        collectionView.contentInset = UIEdgeInsetsMake(0, insetLeft, 0, insetLeft)
        
    }
    private func makeConstraint(){
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([NSLayoutConstraint(item: collectionView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0),NSLayoutConstraint(item: collectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0),NSLayoutConstraint(item: collectionView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0),NSLayoutConstraint(item: collectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)])
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0),NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0),NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0),NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 30)])
    }
    private func addTimer(){
        if (!autoCircle || pictureUrls.isEmpty){
            return
        }
        if timer == nil{
            timer = PHTimer(interval: DispatchTimeInterval.seconds(duration), repeats: true, leeway: DispatchTimeInterval.seconds(duration), queue: DispatchQueue.main, handler: {[weak self] (t) in
                self?.scrollPreOrNextItem(pre: false)
            })
        }
    
        timer?.start()
    }
    private func removeTimer(){
        if (!autoCircle || pictureUrls.isEmpty){
            return
        }
        timer?.suspend()
        timer = nil
    }
    ///移动到上一个或下一个Item
    private func scrollPreOrNextItem(pre:Bool){
        if pre{
            if let preIndexPath = getPreIndexPath(current: lastIndexPath){
                scrollToItem(indexPath: preIndexPath, animate: true)
            }
            
        }else{
            if let nextIndexPath = getNextIndexPath(current: lastIndexPath){
                scrollToItem(indexPath: nextIndexPath, animate: true)
            
            }
        }
    }
    
    private func backToCenterSection(){
        if pictureUrls.isEmpty{
            return
        }
        if pictureUrls.count == 1 && !onePactureCircle{
            return
        }
        if lastIndexPath.section == (SectionNum/2 + 1){
            return
        }
        scrollToItem(indexPath: IndexPath(item: lastIndexPath.row, section: SectionNum/2 + 1), animate: false)
    }
    ///移动到指定的Item
    private func scrollToItem(indexPath:IndexPath,animate:Bool){

        
        guard let attr = layout.layoutAttributesForItem(at: indexPath) else{
            return
        }

        let offsetX = attr.frame.midX - (collectionView.frame.width/2-collectionView.contentInset.left) - collectionView.contentInset.left

        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animate)
        
        if !animate{
            makeCenterCellToTop(indexPath: indexPath)
            
        }
        
    }
    ///中间cell显示在顶部
    private func makeCenterCellToTop(indexPath:IndexPath?){
        
        
        var centerIndexPath:IndexPath!
        if let path = indexPath{
            centerIndexPath = path
        }else{
            let centerPoint = convert(CGPoint(x: bounds.width/2, y: bounds.height/2), to: collectionView)
            guard let path = collectionView.indexPathForItem(at: centerPoint) else{
                return
            }
            centerIndexPath = path
        }


        let preIndexPath = getPreIndexPath(current: centerIndexPath)
        let nextIndexPath = getNextIndexPath(current: centerIndexPath)



        if let pre = preIndexPath,let cell = collectionView.cellForItem(at: pre){
            cell.layer.zPosition = 0
        }
        if let next = nextIndexPath,let cell = collectionView.cellForItem(at: next){
            cell.layer.zPosition = 0
        }
        if let centerCell = collectionView.cellForItem(at: centerIndexPath){
            centerCell.layer.zPosition = 100
        }

        if (lastIndexPath.item,lastIndexPath.section) == (centerIndexPath.item,centerIndexPath.section){
            return
        }
        lastIndex = centerIndexPath.item
        lastIndexPath = centerIndexPath
        pageControl.currentPage = lastIndex
        delegate?.phTransformScrollPictureItemChange?(index:lastIndex)
    }
    
    private func getPreIndexPath(current:IndexPath)->IndexPath?{
        var pre:IndexPath?
        switch (current.item,current.section) {
        case let (item,section) where item == 0 && section > 0:
            
            pre = IndexPath(item: collectionView.numberOfItems(inSection: section-1)-1, section: section-1)
            
        case let (item,section) where item > 0:
            
            pre = IndexPath(item: item-1, section: section)
            
        default:
            break
        }
        return pre
    }
    private func getNextIndexPath(current:IndexPath)->IndexPath?{
        var next:IndexPath?
        switch (current.row,current.section) {
            
        case let (item,section) where item == collectionView.numberOfItems(inSection: section)-1 && section < collectionView.numberOfSections-1:
            
            next = IndexPath(item: 0, section: section+1)
            
        case let (item,section) where item < collectionView.numberOfItems(inSection: section)-1:
            
            next = IndexPath(item: item + 1, section: section)
            
        default:
            break
        }
        return next
    }
    deinit {
        if timer != nil{
            timer?.suspend()
            timer = nil
        }
    }
}

// MARK: - delagate
extension PHTransformScrollPicture:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if pictureUrls.isEmpty{
            return 0
        }else if pictureUrls.count == 1{
            return onePactureCircle ? SectionNum : 1
        }else{
            return SectionNum
        }
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureUrls.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PHTransformScrollPictureCell = collectionView.dequeueReusableCell(withReuseIdentifier: "picture", for: indexPath) as! PHTransformScrollPictureCell
        cell.picture.contentMode = imgContentModel
        if let url = URL(string: pictureUrls[indexPath.item]){
            cell.picture.kf.setImage(with: url)
        }else{
            cell.picture.image = nil
        }
        
        
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == lastIndexPath.row && indexPath.section == lastIndexPath.section{
            cell.layer.zPosition = 100
        }else{
            cell.layer.zPosition = 0
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = bounds.height > 10 ? bounds.height - 10 : 0
        let w = delegate?.phTransformScrollPictureItemWidth() ?? defaultItemWidth
        return CGSize(width: w, height: h)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return delegate?.phTransformScrollPictureMinimumLineSpacing() ?? defaultItemWidth
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.phTransformScrollPictureSelect?(index: indexPath.item)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        removeTimer()
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addTimer()
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        makeCenterCellToTop(indexPath: nil)
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        backToCenterSection()
    }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        backToCenterSection()
    }
    
}
