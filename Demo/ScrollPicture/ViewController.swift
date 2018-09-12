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
        scrollPic.pictureUrls = ["",""]
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
