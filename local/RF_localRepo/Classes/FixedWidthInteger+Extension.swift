//
//  FixedWidthInteger+Extension.swift
//  RF_localRepo
//
//  Created by zrf on 2021/6/8.
//

import Foundation

public extension FixedWidthInteger {
    //整型转浮点型
    var f: Float {
        return Float(self)
    }
    var cgf : CGFloat {
        return CGFloat(self)
    }
    var d: Double {
        return Double(self)
    }
    var str: String{
        return String(format: "\(self)" )
    }
}
