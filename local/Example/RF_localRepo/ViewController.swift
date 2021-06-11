//
//  ViewController.swift
//  RF_localRepo
//
//  Created by zrf on 06/07/2021.
//  Copyright (c) 2021 zrf. All rights reserved.
//

import UIKit
import RF_localRepo

class ViewController: UIViewController {
    var bnView : BannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let str = "0123456789abcdf"
        let data: Data! = str.data(using: .utf8)
        print(123)
        lsPrint(123)
        lsPrint(data.hexString)
        lsPrint("md5 0123456789abcdf:" + str.md5)
        lsPrint("sha256 0123456789abcdf:" + str.sha256)
        lsPrint(str.base64 + " " + str.decodeBase64)
        lsPrint("扫描大师".local)
        @RFPathProtected var path: String = "w3w/1/2/3"
        @RFPathProtected var path1: String = "w4/1"
        @RFPathProtected var path2: String = "w1/1/2/3"
        @RFPathProtected var path3: String = "w4/1/2/3"
        RFPathManager.create(path3, data: "123qw写点东西".data(using: .utf8)!)
        RFPathManager.copy("w4", to:"w5")
        
        lsPrint("读取文件内容Data:"+RFPathManager.data(path3)!.string)
        RFPathManager.insert(path3, data: "\n\n换\n能不能顺利的插入到后面进入呀".data(using: .utf8)!)
        lsPrint("读取文件片段:" + RFPathManager.read(path3, from: 1, length: 10).string)
        lsPrint("获取当前子路径列表:" + RFPathManager.getCurPaths("w2w").description) //获取当前子路径列表["1"]
        lsPrint("获取所有子路径列表:" + RFPathManager.getSubPaths(RFPathManager.prefixDocPath).description)//获取所有子路径列表["w3w", "w3w/1", "w3w/1/2", "w4", "w4/1", "w4/1/2", "w4w", "w4w/1", "w4w/1/2", "w1", "w1/1", "w1/1/2", "w2w", "w2w/1", "w2w/1/2"]
        lsPrint("获取文件夹下文件列表:" + RFPathManager.getSubFiles(RFPathManager.prefixDocPath).description)
        print(RFPathManager.size("Log/log.txt"))
        
        let bannerView = UIView.loadFromNib(named: "BannerView")
        if let bannerView = bannerView {
            bnView = bannerView as? BannerView
            view.addSubview(bannerView)
            bnView.frame = CGRect(x: 0, y: lsSafeTop, width:lsScreenWidth , height: 200)
            bnView.setNeedsUpdateConstraints()
        }
            
    }
    override func viewDidLayoutSubviews() {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

