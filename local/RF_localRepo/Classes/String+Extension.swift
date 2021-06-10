//
//  String+Extension.swift
//  Pods
//
//  Created by zrf on 2021/6/7.
//

import Foundation
import CommonCrypto

public extension String{
    //MARK: md5|文件md5|其他加解密
    var md5:String {  //md5格式输出
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
   
    /*
     *
     当string为本地文件路径时，根据文件生成MD5
     文件的MD5
     */
    var fileMd5: String? {
        let url = URL.init(fileURLWithPath: self)

        let bufferSize = 1024*1024

        do{
            //打开文件
            let file = try FileHandle(forReadingFrom: url)

            defer{
                file.closeFile()
            }
            //初始化内容
            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)
            //读取文件信息
            while case let data = file.readData(ofLength: bufferSize), data.count>0{
                data.withUnsafeBytes{
                _ = CC_MD5_Update(&context, $0,CC_LONG(data.count))
                }
            }
            //计算Md5摘要
            var digest = Data(count:Int(CC_MD5_DIGEST_LENGTH))
            
            digest.withUnsafeMutableBytes {
                _=CC_MD5_Final($0, &context)
            }
            
            return digest.map{String(format:"%02x", $0) }.joined()
            
        }catch{
            
            print("rf Cannot open file:", error.localizedDescription)
            
            return nil
        }
    }
    var sha1:String {  //sha1格式输出
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
    var sha256: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }

   
    //base64编码
    var base64: String{
        return self.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
    }
    var decodeBase64 : String {
        let enData = self.data(using: String.Encoding.utf8)!
        let str = String(data: enData, encoding: String.Encoding.utf8)
        return str!
    }
    //url编码, 编码失败返回自身
    var urlEncode : String {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    //url解码
    var urlDecode : String {
        return removingPercentEncoding ?? self
    }
    var data: Data{
        self.data(using: .utf8)!
    }
    //MARK: 验证
    //邮箱验证
    var isEmail: Bool {
        if isEmpty {
            return false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    //手机号验证
    var isPhone: Bool {
        if isEmpty {
            return false
        }
        let mobile = "^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        return regexMobile.evaluate(with: self)
    }
    
    var bytes:UnsafeRawPointer{
        let data = self.data(using: String.Encoding.utf8)!
        return (data as NSData).bytes
    }
    // MARK: cbc
    func aesCBCEncrypt(_ key:String,iv:String? = nil) -> Data? {
        let data = self.data(using: String.Encoding.utf8)
        return data?.aesCBCEncrypt(key, iv: iv)
    }
    
    func aesCBCDecryptFromHex(_ key:String,iv:String? = nil) ->String?{
        let data = self.dataFromHexadecimalString()
        guard let raw_data = data?.aesCBCDecrypt(key, iv: iv) else{
            return nil
        }
        return String(data: raw_data, encoding: String.Encoding.utf8)
    }
    
    func aesCBCDecryptFromBase64(_ key:String, iv:String? = nil) ->String? {
        let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions())
        guard let raw_data = data?.aesCBCDecrypt(key, iv: iv) else{
            return nil
        }
        return String(data: raw_data, encoding: String.Encoding.utf8)
    }
    private func dataFromHexadecimalString() -> Data? {
            let trimmedString = self.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
            
            guard let regex = try? NSRegularExpression(pattern: "^[0-9a-f]*$", options: NSRegularExpression.Options.caseInsensitive) else{
                return nil
            }
            let trimmedStringLength = trimmedString.lengthOfBytes(using: String.Encoding.utf8)
            let found = regex.firstMatch(in: trimmedString, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, trimmedStringLength))
            if found == nil || found?.range.location == NSNotFound || trimmedStringLength % 2 != 0 {
                return nil
            }
          
            var data = Data(capacity: trimmedStringLength / 2)
            
            for index in trimmedString.indices {
                let next_index = trimmedString.index(after: index)
                let byteString = String(trimmedString[index ..< next_index]) //trimmedString.substring(with: )
                let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
                data.append(num)
            }
            return data
        }
    /// SwifterSwift: Check if string contains one or more emojis.
    ///
    ///        "Hello 😀".containEmoji -> true
    ///
    var containEmoji: Bool {
        // http://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x1F1E6...0x1F1FF, // Regional country flags
                 0x2600...0x26FF, // Misc symbols
                 0x2700...0x27BF, // Dingbats
                 0xE0020...0xE007F, // Tags
                 0xFE00...0xFE0F, // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 127_000...127_600, // Various asian characters
                 65024...65039, // Variation selector
                 9100...9300, // Misc items
                 8400...8447: // Combining Diacritical Marks for Symbols
                return true
            default:
                continue
            }
        }
        return false
    }
    /// SwifterSwift: Check if string contains one or more letters.
    ///
    ///        "123abc".hasLetters -> true
    ///        "123".hasLetters -> false
    ///
    var hasLetters: Bool {
        return rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
    }

    /// SwifterSwift: Check if string contains one or more numbers.
    ///
    ///        "abcd".hasNumbers -> false
    ///        "123abc".hasNumbers -> true
    ///
    var hasNumbers: Bool {
        return rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
    }  
    /// SwifterSwift: Check if string is a valid Swift number. Note: In North America, "." is the decimal separator, while in many parts of Europe "," is used.
    ///
    ///        "123".isNumeric -> true
    ///     "1.3".isNumeric -> true (en_US)
    ///     "1,3".isNumeric -> true (fr_FR)
    ///        "abc".isNumeric -> false
    ///
    var isNumeric: Bool {
        let scanner = Scanner(string: self)
        scanner.locale = NSLocale.current
        #if os(Linux) || targetEnvironment(macCatalyst)
        return scanner.scanDecimal() != nil && scanner.isAtEnd
        #else
        return scanner.scanDecimal(nil) && scanner.isAtEnd
        #endif
    }
    /// SwifterSwift: Integer value from string (if applicable).
    ///
    ///        "101".int -> 101
    ///
    var int: Int? {
        return Int(self)
    }
    /// SwifterSwift: String with no spaces or new lines in beginning and end.
    ///
    ///        "   hello  \n".trimmed -> "hello"
    ///
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    /// SwifterSwift: Copy string to global pasteboard.
    ///
    ///        "SomeText".copyToPasteboard() // copies "SomeText" to pasteboard
    ///
    func copyToPasteboard() {
        #if os(iOS)
        UIPasteboard.general.string = self
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
        #endif
    }
    /// SwifterSwift: Create a new random string of given length.
    ///
    ///        String(randomOfLength: 10) -> "gY8r3MHvlQ"
    ///
    /// - Parameter length: number of characters in string.
    init(randomOfLength length: Int) {
        guard length > 0 else {
            self.init()
            return
        }

        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 1...length {
            randomString.append(base.randomElement()!)
        }
        self = randomString
    }
    func dict()  throws -> Any{
        let data = self.data(using: .utf8)
        return try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
    }
}

public extension String{
    //MARK: 国际化
    /**
     demo
     String.language = .cn  //  此行在本地改变语言后赋值，默认显示中文
     print("扫描大师".local)  //打印出：万能扫描大师
     
     中文："扫描大师" = "万能扫描大师";
     英文："扫描大师" = "master scanner";
     */
    enum RFLocalizedType: String {
        case en = "en"   //英文  字符串需要对应本地的国际化文件名(.lproj)
        case cn = "zh-Hans"     //简体中文
        case hk = "zh-Hant"    //繁体中文
    }
    static var language : RFLocalizedType = currentLanguage()     //当前显示的语言，需全局存储维护，更改语言时值改变.默认为当前系统语言
    static let tableName: String = "Localizable"  //国际化文件名，如本地自定义名，修改此处
    var local : String {
        let bundle = Bundle(path: Bundle.main.path(forResource: String.language.rawValue, ofType: "lproj") ?? "")
        if let bundle = bundle {
            return NSLocalizedString(self, tableName: String.tableName, bundle:bundle , value: self, comment: "")
        }else{
            //未找到国际化内容
            return self
        }
        
    }
    //获取当前系统语言:如"zh-Hans-CN"  简体中文
    static var current : String {
        return Locale.preferredLanguages.first ?? ""
    }
    private static func currentLanguage() -> RFLocalizedType {
        if current.lowercased().contains("zh-hans") { //简体中文
            return .cn
        }else if current.lowercased().contains("zh-hans") {
            return .hk
        }else{
            return .en
        }
    }
}

