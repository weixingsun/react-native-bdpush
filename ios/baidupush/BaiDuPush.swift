//
//  BaiDuPush.swift
//  Created by qiepeipei on 16/8/14.
//  Copyright © 2016年 Facebook. All rights reserved.
//
import UIKit

@objc(BaiDuPush)
class BaiDuPush: RCTEventEmitter {
  //var bridge: RCTBridge!
  override func supportedEvents() -> [String]! {
    return ["PushStateEvent","PenetrateEvent","PushEvent"]
  }
  override init() {
    super.init()
    //消息初始化
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.getMyName),
      name:NSNotification.Name(rawValue: "NotificationIdentifier"),
      object: nil)
  }
  
  //收到透传推送消息
  static func receivePushMessages(_ msg:String){
    DispatchQueue.main.async{
      let dic = ["msg":msg,"state":1] as [String : Any];
      NotificationCenter.default.post(name: Notification.Name(rawValue: "NotificationIdentifier"), object: dic)
    }
  }
  
  //收到通知推送消息
  static func pushNotificationMessages(_ msg:String){
    DispatchQueue.main.async{
      let dic = ["msg":msg,"state":2] as [String : Any];
      NotificationCenter.default.post(name: Notification.Name(rawValue: "NotificationIdentifier"), object: dic)
    }
  }
  
  //消息回调
  func getMyName(_ notification:Notification){
    let state = (notification.object as AnyObject).value(forKey: "state") as? Int
    let msg = (notification.object as AnyObject).value(forKey: "msg") as? String
    self.event_penetrate_msg(msg!,state:state!)
  }
  
  //发送消息  1透传 2通知
  func event_penetrate_msg(_ msg:String,state:Int){
    if state == 1{
      //发送透传消息
      self.sendEvent(withName: "PenetrateEvent", body: msg)
    }else{
      //发送通知消息
      self.sendEvent(withName: "PushEvent",body: msg)
    }
  }
  
  //在 App 启动时注册百度云推送服务，需要提供 Apikey
  static func registerChannel(_ application:NSDictionary,apiKey:String,pushMode:BPushMode){
    DispatchQueue.main.async{
      BPush.registerChannel(application as! [AnyHashable: Any], apiKey: apiKey, pushMode: pushMode, withFirstAction: "打开", withSecondAction: "回复", withCategory: "test", useBehaviorTextInput: true, isDebug: true)
    }
  }
  
  // 禁用地理位置推送 需要再绑定接口前调用。
  static func disableLbs(){
      DispatchQueue.main.async{
      BPush.disableLbs()
    }
  }
  
  //推送消息的反馈和统计
  static func handleNotification(_ userInfo:NSDictionary){
    DispatchQueue.main.async{
      BPush.handleNotification(userInfo as! [AnyHashable: Any])
    }
  }
  
  //向百度云注册
  static func registerDeviceToken(_ deviceToken:Data){
    DispatchQueue.main.async{
      BPush.registerDeviceToken(deviceToken)
    }
  }
  
  //绑定Push服务通道
  @objc func bindChannelWithCompleteHandler(_ callback: @escaping ([String:String]) -> ()){
    DispatchQueue.main.async{
      var ret = ["error_code":"-1"]
      let callback:BPushCallBack = {(result:Any?, error:Error?) in
        if error != nil{
          callback(["error_code":"-2"])
          return
        }
        //let str_channel_id = (result as AnyObject).object(forKey:"channel_id")
        let channel_id = (result as AnyObject).object(forKey:"channel_id")
        let str_channel_id = channel_id as! String
        //print("channel_id=\(str_channel_id)")
        // 确认绑定成功
        //let error_code = (result as AnyObject).object(forKey:"error_code") as! String
        if (str_channel_id.characters.count > 0){  //error_code != nil &&
          ret=[
            "msgState":"1",
            "channel_id":str_channel_id,
            "app_id":"8851029",
            //"request_id":"88888888",
            //"user_id":"631682946656437185",
            ]
          //callback(ret)
          print("sucessfully binded")
          return
        }else{
          print("failed to bind")
          //callback(ret)
        }
      }
      BPush.bindChannel(completeHandler:callback )
      self.sendEvent(withName: "PushStateEvent",body: ret)
    }
  }
  
  //解除绑定Push服务通道
  @objc func unbindChannelWithCompleteHandler(callback: @escaping (NSNumber) -> ()){
    DispatchQueue.main.async{
      let callback:BPushCallBack = {(result:Any?, error:Error?) in
        if error != nil{
          callback(-2)
          return
        }
        // 确认是否解绑绑定成功
        if (result as AnyObject).object(forKey:"request_id") == nil{
          callback(-1)
          return
        }else{
          callback(0)
          print("解绑成功")
        }
      }
      
      BPush.unbindChannel (completeHandler:callback )
    }
  }
  
  //设置tags
  @objc func setTag(_ tags:String,callback: @escaping (NSNumber) -> ()){
    DispatchQueue.main.async{
      let callback:BPushCallBack = { (result:Any?, error:Error?) in
        // 确认是否设置成功
        let error_code = (result as AnyObject).object(forKey:"error_code") as! Int
        if ( error_code == 0){  //error_code != nil &&
          callback(0)
          return
        }else{
          callback(-1)
          print("设置tags成功")
        }
      }
      BPush.setTag(tags, withCompleteHandler: callback)
    }
  }
  
  //删除tags
  @objc func delTag(_ tags:String,callback: @escaping (NSNumber) -> ()){
    DispatchQueue.main.async{
      BPush.delTag(tags, withCompleteHandler: { (result:Any?, error:Error?) in
        // 确认是否删除成功
        let error_code = (result as AnyObject).object(forKey:"error_code") as! Int
        if (error_code == 0){
          callback(0)
          return
        }else{
          callback(-1)
          print("删除tags成功")
        }
      })
    }
  }
}
