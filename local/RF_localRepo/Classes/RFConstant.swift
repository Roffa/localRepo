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
 @brief 屏幕宽度
 */
public var lsScreenWidth : CGFloat {
    UIScreen.main.bounds.size.width
}
public var lsScreenHeight : CGFloat {
    UIScreen.main.bounds.size.height
}
//顶部安全区域
public var lsSafeTop : CGFloat {
    if #available(iOS 11.0, *),
        let window = UIApplication.shared.keyWindow {
        return window.safeAreaInsets.top
    }
    return 20
}
//底部安全区域
public var lsSafeBottom : CGFloat {
    if #available(iOS 11.0, *),
        let window = UIApplication.shared.keyWindow {
        return window.safeAreaInsets.bottom
    }
    return 0
}
//获取本地framework资源信息
//当pod使用 user_framework时，需要从framework中读取到bundle，未使用时可直接获取
public func myBundle(_ name: String = "RF_localRepo", framework: String = "RF_localRepo") -> Bundle?{
    let frameworkUrl = Bundle.main.url(forResource: "Frameworks", withExtension: nil)  //获取framework
//    let url = Bundle.main.url(forResource: name, withExtension: "bundle")  //没有user_framework时直接使用
//    if let url = url {
//        return Bundle(url: url)
//    }
    var bundleUrl = frameworkUrl?.appendingPathComponent(framework)
    bundleUrl?.appendPathExtension("framework")
    if let bundleUrl = bundleUrl {
        let bundle = Bundle(url: bundleUrl)
        let url = bundle?.url(forResource: name, withExtension: "bundle")
        let myBundle = Bundle(url: url!)
        return myBundle
    }else{
        return nil
    }
//    self.imagView.image = [UIImage imageNamed:@"icon_mine_grade"
//      inBundle: bundle
//    compatibleWithTraitCollection:nil];
}
/**
 @brief 自定义打印，只有debug模式下，控制台会打印出信息
 */
public func lsPrint(_ items: Any..., file: String = #file, function: String = #function, isSave: Bool = true){
    
    var log = Date().string() + " " + (file as NSString).lastPathComponent + "." + function + " "
    for item in items{
        if let value = item as? String{
            log += value
        }else if let value = item as? CustomStringConvertible {
            log += value.description
        }
    }
    log += "\n"
    #if DEBUG
    print(log)
    #endif
    if isSave {
        let logPath = "Log/log.txt"
        if RFPathManager.size(logPath) > 1_024_000 {  //文件大于1000K时自动清理
            RFPathManager.del(logPath)
        }
        RFPathManager.insert(logPath, data: log.data)
    }
    
}
