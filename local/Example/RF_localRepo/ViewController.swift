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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let str = "123456789as"
        let data: Data! = str.data(using: .utf8)
        print(data.hexString)
        print(str.md5)
        print(str.base64 + " " + str.decodeBase64)
        print("扫描大师".local)
        @RFPathProtected var path: String = "w3w/1/2/3"
        @RFPathProtected var path1: String = "w4/1"
        @RFPathProtected var path2: String = "w1/1/2/3"
        @RFPathProtected var path3: String = "w4/1/2/3"
        RFPathManager.create(path3, data: "123qw写点东西".data(using: .utf8)!)
//        RFPathManager.copy("w4", to:"w5")
        RFPathManager.del("w5/1/")
        print(RFPathManager.data(path3)!.string)
        RFPathManager.insert(path3, data: "\n\n换\n能不能顺利的插入到后面进入呀".data(using: .utf8)!)
        print(RFPathManager.read(path3, from: 1, length: 10).string)
        print(path)
        print("获取当前子路径列表" + RFPathManager.getCurPaths("w2w").description) //获取当前子路径列表["1"]
        print("获取所有子路径列表" + RFPathManager.getSubPaths(RFPathManager.prefixDocPath).description)//获取所有子路径列表["w3w", "w3w/1", "w3w/1/2", "w4", "w4/1", "w4/1/2", "w4w", "w4w/1", "w4w/1/2", "w1", "w1/1", "w1/1/2", "w2w", "w2w/1", "w2w/1/2"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

