
//
//  GRApiManager.swift
//  Pods
//
//  Created by Gnatsel Reivilo on 23/06/2016.
//
//

import UIKit
import Alamofire
import PromiseKit
import Argo
import CoreData
import Foundation

public typealias GRRequestMethod = Alamofire.Method
public typealias GRParameterEncoding = Alamofire.ParameterEncoding

public enum GRApiManagerError<T>:ErrorType {
  case invalid(data:T?)
}

public enum GRMultipartFormDataBodyPart {
  case data(data:NSData)
  case fileURL(fileURL:NSURL)
  case string(string:String)
}

public class GRApiManager: NSObject {
  public var encoding:GRParameterEncoding = .URL
  public var requestMethod:GRRequestMethod = .GET
  public var url:String = ""
  public var headers:[String:String]?
  private static var sharedInstancesDictionary = [String:GRApiManager]()

  
  class func sharedInstance<T:GRApiManager>() -> T{
    let classname = GRUtils.stringFromClass(self)
    if sharedInstancesDictionary[classname] != nil {
      return (sharedInstancesDictionary[classname]) as! T
    }
    else {
      let singletonObject = self.init()
      sharedInstancesDictionary[classname] = singletonObject
      return singletonObject as! T
    }
  }
  
  required override public init(){
    super.init()
  }
  
  public func performRequest<T:Decodable where T == T.DecodedType>(
    parameters:[String:AnyObject]? = nil)
    -> Promise<T>{
      return Promise { fullfill, reject in
        Alamofire.request(requestMethod, url, parameters: parameters, encoding: encoding, headers: headers).responseJSON{ response in
          switch(response.result){
          case let .Success(j):
            guard let value:T = decode(j) else {
              dispatch_async(dispatch_get_main_queue()) {
                reject(GRApiManagerError.invalid(data: response.data))
              }
              return
            }
            dispatch_async(dispatch_get_main_queue()) {
              fullfill(value)
            }
          case let .Failure(error):
            dispatch_async(dispatch_get_main_queue()) {
              reject(error)
            }
          }
          
        }
      }
  }
  
  public func performRequest<T:Decodable where T == T.DecodedType>(
    parameters:[String:AnyObject]? = nil)
    -> Promise<[T]>{
      return Promise { fullfill, reject in
        Alamofire.request(requestMethod, url, parameters: parameters, encoding: encoding, headers: headers).responseJSON{ response in
          switch(response.result){
          case let .Success(j):
            guard let value:[T] = decode(j) else {
              dispatch_async(dispatch_get_main_queue()) {
                reject(GRApiManagerError.invalid(data: response.data))
              }
              return
            }
            dispatch_async(dispatch_get_main_queue()) {
              fullfill(value)
            }
          case let .Failure(error):
            dispatch_async(dispatch_get_main_queue()) {
              reject(error)
            }
          }
          
        }
      }
  }
  
  public func upload<T:Decodable where T == T.DecodedType>(multipartFormDataBodyParts:[String:GRMultipartFormDataBodyPart]) -> Promise<T>{
    return Promise { fullfill, reject in
      Alamofire.upload(requestMethod, url, headers: headers, multipartFormData: { (multipartFormData) in
        multipartFormDataBodyParts.forEach{ (key, multipartFormDataBodyPart) in
          switch multipartFormDataBodyPart {
          case .data(let data) :
            multipartFormData.appendBodyPart(data: data, name: key)
          case .fileURL(let fileURL) :
            multipartFormData.appendBodyPart(fileURL: fileURL, name: key)
          case .string(let string) :
            guard let data = string.dataUsingEncoding(NSUTF8StringEncoding) else {
              dispatch_async(dispatch_get_main_queue()) { reject(GRApiManagerError.invalid(data: string)) }
              return
            }
            multipartFormData.appendBodyPart(data: data, name: key)
          }
        }
        
      }, encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold) { (multipartFormDataEncodingResult) in
        switch multipartFormDataEncodingResult {
        case .Success(let upload, _, _):
          upload.responseJSON { response in
            switch response.result {
            case let .Success(j):
              guard let value:T = decode(j) else {
                dispatch_async(dispatch_get_main_queue()) {
                  reject(GRApiManagerError.invalid(data: response.data))
                }
                return
              }
              dispatch_async(dispatch_get_main_queue()) {
                fullfill(value)
              }
            case let .Failure(error):
              dispatch_async(dispatch_get_main_queue()) {
                reject(error)
              }
            }
          }
        case .Failure(let encodingError):
          reject(encodingError)
        }
      }
    }
  }
}
