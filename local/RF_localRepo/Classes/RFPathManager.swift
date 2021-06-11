//
//  RFPathManager.swift
//  RF_localRepo_Example
//
//  Created by zrf on 2021/6/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

//路径属性包装器，自动创建路径
//@RFPathProtected var path: String = RFPathManager.prefixDocPath + "w2w/1/2/3"  //自动创建路径到2为止.
@propertyWrapper
public struct RFPathProtected {
    private var path: String = ""
    public var wrappedValue: String {
        get { return path }
        set {
            path = RFPathManager.path(newValue) ?? ""
        }
    }
    public init(wrappedValue: String) {
        path = RFPathManager.path(wrappedValue) ?? ""
    }
}

open class RFPathManager {
    public static let shared = RFPathManager()
    private init(){
        
    }
    
    public static var headerPath = "Local"
    /**
     @brief 存储在本地Documents目录下的根路径.iTunes备份和恢复的时候会包括此目录
     */
    public static var prefixDocPath :  String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last ?? ""
        let fPath = path + "/" + headerPath + "/"
        return fPath
    }
    /**
     @brief 存储在本地Library目录下的根路径
    与上面的区别：当系统内存不足时，此路径的存储信息会被自动清理,
     */
    public static var prefixLibPath :  String {
//        let manager = FileManager.default
//        let urlForDocument = manager.urls(for: .documentDirectory, in:.userDomainMask)
//        let url = urlForDocument[0] as URL
//        print(url)
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last ?? ""
        let fPath = path + "/" + headerPath  + "/"
        return fPath
    }
    /**
     @brief 是否存在指定路径
     @param path 路径名，如"\(NSHomeDirectory())/Documents/LongPhoto". 当路径名只"LongPhone", 自动拼接成prefixDocPath+path形式
     @return 返回true || false
     @author rf/2021-06-10
     */
    public static func bExist(path: String) -> Bool {
        guard !path.isEmpty else {
            return false
        }
        return FileManager.default.fileExists(atPath: normalPath(path: path))
    }
    /**
     @brief 自动拼接字路径
     @discussion 当传入的路径非标准路径时，进行自动拼接操作
     */
    private static func normalPath(path: String) -> String{
        guard path.contains(prefixLibPath) || path.contains(prefixDocPath) else {
            var url = URL(fileURLWithPath: prefixDocPath)
            url.appendPathComponent(path)
            return url.path
        }
        return path
    }
    /**
     @brief 文件路径检查，当路径存在，之间返回原对象，不存在本地创建完毕后返回
     @param path 文件路径，可传染string或URL
     @discussion 如文件父路径不存在，自动创建。 当path定义为属性时，使用上面属性包装器更加便捷
     
     */
    public static func path<T>(_ path: T) -> String?{
        var url : URL?
        if path is String {
            url = URL(fileURLWithPath: normalPath(path: (path as! String)))
        }else if path is URL {
            url = URL(fileURLWithPath: normalPath(path: (path as! URL).path))
        }
//        let fPath = url!.path
        guard let url = url else {
            return nil
        }
        let superPath = url.path.replacingOccurrences(of: "/" + url.lastPathComponent, with: "")
        if bExist(path: superPath) {  //父路径是否存在，不存在则创建
            return url.path
        }else{
            do {
                try FileManager.default.createDirectory(atPath: superPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print(error)
            }
            
        }
        return url.path
    }
    /**
     @brief 根据指定路径保存文件， 支持Data/String/UIImage/NSArray/NSDictionary
     */
    @discardableResult
    public static func create<T>(_ path: String, data: T) -> Bool{
        guard !path.isEmpty else {
            return false
        }
        let fpath = self.path(path) ?? ""
        
        if let data = data as? Data {
            return FileManager.default.createFile(atPath: fpath, contents: data, attributes: nil)
        }else if let str = data as? String{
            return (try? str.write(toFile: fpath, atomically: true, encoding: String.Encoding.utf8)) != nil
        }else if let img = data as? UIImage{
            let data = img.jpegData(compressionQuality: 1)!
            return (try? data.write(to: URL(fileURLWithPath: fpath))) != nil
        }else if let array = data as? NSArray{
            array.write(toFile: fpath, atomically: true)
        }else if let dict = data as? NSDictionary{
            dict.write(toFile: fpath, atomically: true)
        }
        return false
    }
    /**
     @brief 文件中插入内容
     @param offset 文件偏移位置
     */
//    @available(iOS 13.4, *)
    public static func insert(_ path: String, data: Data, offset: UInt64 = 0){
        guard !path.isEmpty else {
            return
        }
        guard data.count > 0 else {
            return
        }
        let fpath = self.path(path) ?? ""
        if !bExist(path: fpath) {  //当文件不存在时，先创建文件
            create(fpath, data: data)
        }else{
            if let handler = FileHandle(forWritingAtPath: fpath){
                if offset < 1 {
                    handler.seekToEndOfFile()
                }else {
                    handler.seek(toFileOffset: offset)
                }
                handler.write(data)
            }
        }
        
    }
    /**
     @brief 文件中读取内容片段
     @param from 文件开始读取位置
     */
//    @available(iOS 13.4, *)
    public static func read(_ path: String, from: UInt64 = 0, length: Int = 0) -> Data{
        guard !path.isEmpty else {
            return Data()
        }
        let fpath = self.path(path) ?? ""
        if let handler = FileHandle(forReadingAtPath: fpath){
            handler.seek(toFileOffset: from)
            if length < 1 {  //全部读取
                return handler.readDataToEndOfFile()
            }else {
                return handler.readData(ofLength: length)
            }
        }
        return Data()
    }
    /**
     @brief 文件复制
     */
    @discardableResult
    public static func copy(_ path: String, to: String) -> Bool{
        if bExist(path: normalPath(path: to)) { //如目标路径存在，先删除目标路径
            del(normalPath(path: to))
        }
        return (try? FileManager.default.copyItem(at: URL(fileURLWithPath: normalPath(path: path)), to: URL(fileURLWithPath: normalPath(path: to))) ) != nil
    }
    /**
     @brief 文件移动
     */
    @discardableResult
    public static func move(_ path: String, to: String)-> Bool{
        return (try? FileManager.default.moveItem(at: URL(fileURLWithPath: normalPath(path: path)), to: URL(fileURLWithPath: normalPath(path: to))) ) != nil
    }
    /**
     @brief 文件删除, 子目录同时被删除
     */
    @discardableResult
    public static func del(_ path: String)-> Bool{
        do {
            try FileManager.default.removeItem(atPath: normalPath(path: path))
            return true
        } catch let error {
            print("删除本地文件失败:" + error.localizedDescription)
        }
        return false
    }
    /**
     @brief 获取当前路径下所有子目录。子目录下层目录不会返回，不区分文件与文件夹
     */
    public static func getCurPaths(_ path: String) -> [String]{
        guard !path.isEmpty else {
            return []
        }
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: normalPath(path: path))
            return contents
        } catch let error {
            lsPrint("读取本地文件失败:" + error.localizedDescription)
        }
        return []
    }
    /**
     @brief 获取当前路径下所有子文件。子目录下层文件不会返回
     */
    public static func getCurFiles(_ path: String) -> [String]{
        guard !path.isEmpty else {
            return []
        }
        do {
            let fpath = normalPath(path: path)
            let contents = try FileManager.default.contentsOfDirectory(atPath: fpath)
            let files = contents.filter{
                var isDirectory = ObjCBool(true)
                let bExist = FileManager.default.fileExists(atPath: fpath+"/"+$0, isDirectory: &isDirectory)
                return !isDirectory.boolValue && bExist
            }
            return files
        } catch let error {
            lsPrint("读取本地文件失败:" + error.localizedDescription)
        }
        return []
    }
    /**
     @brief 获取当前路径下所有子目录。子目录下层目录会返回，不区分文件与文件夹
     */
    public static func getSubPaths(_ path: String) -> [String]{
        guard !path.isEmpty else {
            return []
        }
        let contents = FileManager.default.enumerator(atPath: normalPath(path: path))
        
        return contents?.allObjects as! [String]
    }
    /**
     @brief 获取当前路径下所有子文件。子目录下层文件会返回
     */
    public static func getSubFiles(_ path: String) -> [String]{
        guard !path.isEmpty else {
            return []
        }
        let contents = FileManager.default.enumerator(atPath: normalPath(path: path))
        let array = contents?.allObjects as! [String]
        let files = array.filter{
            var isDirectory = ObjCBool(true)
            let bExist = FileManager.default.fileExists(atPath: normalPath(path: path)+"/"+$0, isDirectory: &isDirectory)
            return !isDirectory.boolValue && bExist
        }
        return files
    }
    /**
     @brief 读取指定路径的文件内容
     */
    public static func data(_ path: String)-> Data?{
        guard !path.isEmpty else {
            return nil
        }
        return FileManager.default.contents(atPath: normalPath(path: path))
    }
    /**
     @brief 获取文件信息  
     */
    fileprivate static func info(_ path: String) -> NSDictionary{
        let dic = try? FileManager.default.attributesOfItem(atPath: normalPath(path: path))
        return (dic as NSDictionary?) ?? NSDictionary()
    }
    public static func size(_ path: String) -> UInt64
    {
        guard !path.isEmpty else {
            return 0
        }
        let info = self.info(normalPath(path: path))
        return info.fileSize()
    }
    public static func createTime(_ path: String) -> Date?
    {
        guard !path.isEmpty else {
            return nil
        }
        let info = self.info(normalPath(path: path))
        return info.fileCreationDate()
    }
    public static func modifyTime(_ path: String) -> Date?
    {
        guard !path.isEmpty else {
            return nil
        }
        let info = self.info(normalPath(path: path))
        return info.fileModificationDate()
    }
    /**
     @brief 读取工程中plist文件到字典
     */
    public static func plist(_ path: String) -> Dictionary<String, Any>{
        guard let url = Bundle.main.url(forResource: path, withExtension: "plist") else {
            return ["":""]
        }
        guard let data = try? Data(contentsOf: url) else {
            return ["":""]
        }
        let dic = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        return dic as! Dictionary<String, Any>
    }
}
