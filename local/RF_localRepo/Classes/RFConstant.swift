//
//  RFConstant.swift
//  RF_localRepo
//
//  Created by zrf on 2021/6/8.
//

import Foundation

public func rgb(r: Int, g: Int, b: Int, a: CGFloat = 1) -> UIColor{
    return UIColor(red: r.cgf/255.0, green: g.cgf/255.0, blue: b.cgf/255.0, alpha: a)
}

public func hexColor(_ hex: Int, a: CGFloat = 1) -> UIColor {
    let red = (hex >> 16) & 0xFF
    let green = (hex >> 8) & 0xFF
    let blue = hex & 0xFF
    return rgb(r: red, g: green, b: blue, a: a)
}
public func hexColor(_ hexString: String, a: CGFloat = 1) -> UIColor {
    var string = ""
    let lowercaseHexString = hexString.lowercased()
    if lowercaseHexString.hasPrefix("0x") {
        string = lowercaseHexString.replacingOccurrences(of: "0x", with: "")
    } else if hexString.hasPrefix("#") {
        string = hexString.replacingOccurrences(of: "#", with: "")
    } else {
        string = hexString
    }

    if string.count == 3 { // convert hex to 6 digit format if in short format
        var str = ""
        string.forEach { str.append(String(repeating: String($0), count: 2)) }
        string = str
    }
    let hexValue = Int(string, radix: 16) ?? 0
    return hexColor(hexValue, a: a)
}
/**
 @brief 获取APP名
 @author rf/2021-06-09
 */
public func appName() -> String {
    if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
        return name
    }else{
        return ""
    }
}
/**
 @brief 获取APP版本号
 @author rf/2021-06-09
 */
public func appVersion() -> String {
    if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
        return name
    }else{
        return ""
    }
}
/**
 @brief 获取APP build num
 @author rf/2021-06-09
 */
public func appBuildNum() -> String {
    if let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
        return name
    }else{
        return ""
    }
}
/**
 @brief 获取APP Bundle ID
 @author rf/2021-06-09
 */
public func appBundleId() -> String {
    if let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String {
        return name
    }else{
        return ""
    }
}
/**
 @brief 自定义打印，只有debug模式下，控制台会打印出信息
 */
func lsPrint(_ items: Any..., isSave: Bool = false){
    #if DEBUG
        print(items)
    #endif
}
