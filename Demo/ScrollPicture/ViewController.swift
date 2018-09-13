//
//  ViewController.swift
//  ScrollPicture
//
//  Created by 彭辉 on 2018/9/10.
//  Copyright © 2018年 彭辉. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    
    
    private lazy var scrollPic:PHTransformScrollPicture = {()->PHTransformScrollPicture in
       let scrollPicture = PHTransformScrollPicture(frame: CGRect(x: 10, y: 100, width: UIScreen.main.bounds.width-20, height: 150))
        scrollPicture.delegate = self
        scrollPicture.onePactureCircle = true
        scrollPicture.autoCircle = false
        return scrollPicture
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollPic)
        scrollPic.pictureUrls = ["https://gss2.bdstatic.com/-fo3dSag_xI4khGkpoWK1HF6hhy/baike/c0%3Dbaike150%2C5%2C5%2C150%2C50/sign=26135adf033b5bb5aada28ac57babe5c/7dd98d1001e939012f18d64a7bec54e736d196af.jpg","https://gss0.bdstatic.com/-4o3dSag_xI4khGkpoWK1HF6hhy/baike/c0%3Dbaike92%2C5%2C5%2C92%2C30/sign=7d31a6b8c3cec3fd9f33af27b7e1bf5a/a1ec08fa513d26979dcd532955fbb2fb4316d8ac.jpg"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    

}
extension ViewController:PHTransformScrollPictureDelegate{
    func phTransformScrollPictureItemWidth() -> CGFloat {
        return 200
    }
    
    func phTransformScrollPictureMinimumLineSpacing() -> CGFloat {
        return -30
    }
    func phTransformScrollPictureItemChange(index: Int) {
        print(index)
    }
    func phTransformScrollPictureSelect(index: Int) {
        print(index)
    }
    
    
}
