//
//  Data+Extension.swift
//  Pods
//
//  Created by zrf on 2021/6/7.
//

import Foundation
import CommonCrypto


public extension Data {
    var hexString: String {  //16进制输出
        var t = ""
        let ts = [UInt8](self)
        
//        for one in ts {
//            t.append(String.init(format: "%02x", one))
//        }
        t = ts.map{String(format:"%02x", $0) }.joined()
        return t
    }
    var bytes: Array<UInt8> {
      Array(self)
    }
    
    var base64 : String{
        self.base64EncodedString(options: Base64EncodingOptions())
    }
    var string: String{
        String(data: self, encoding: .utf8)!
    }
    // MARK: cbc
    fileprivate func aesCBC(_ operation:CCOperation,key:String, iv:String? = nil) -> Data? {
        guard [16,24,32].contains(key.lengthOfBytes(using: String.Encoding.utf8)) else {
            return nil
        }
        let input_bytes = self.bytes
        let key_bytes = key.bytes
        var encrypt_length = Swift.max(input_bytes.count * 2, 16)
        var encrypt_bytes = [UInt8](repeating: 0,
                                    count: encrypt_length)
        
        let iv_bytes = (iv != nil) ? iv?.bytes : nil
        let status = CCCrypt(UInt32(operation),
                             UInt32(kCCAlgorithmAES128),
                             UInt32(kCCOptionPKCS7Padding),
                             key_bytes,
                             key.lengthOfBytes(using: String.Encoding.utf8),
                             iv_bytes,
                             input_bytes,
                             input_bytes.count,
                             &encrypt_bytes,
                             encrypt_bytes.count,
                             &encrypt_length)
        if status == Int32(kCCSuccess) {
            return Data(bytes: encrypt_bytes, count: encrypt_length)
        }
        return nil
    }
    
    func aesCBCEncrypt(_ key:String,iv:String? = nil) -> Data? {
        return aesCBC(UInt32(kCCEncrypt), key: key, iv: iv)
    }
    
    func aesCBCDecrypt(_ key:String,iv:String? = nil)->Data?{
        return aesCBC(UInt32(kCCDecrypt), key: key, iv: iv)
    }
}
