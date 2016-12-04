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
      //print("收到消息")
      let dic = ["msg":msg,"state":1] as [String : Any];
      NotificationCenter.default.post(name: Notification.Name(rawValue: "NotificationIdentifier"), object: dic)
    }
  }
  static func saveNotificationMessages(_ msg:NSDictionary){
    var json = JSON(msg)
    if let type=json["t"].string {  //["custom_content"]["t"]
      //UserDefaults.standard.setValue(msg, forKey: "push_list:\(type)");
      //let ud = UserDefaults.init(suiteName: "com.share")!
      let key = "push_list:\(type)"
      var oldarray = UserDefaults.standard.array(forKey: key) //json string array
      if((oldarray) != nil){
        oldarray!.append(json.rawString()!)
      }else {
        oldarray = [String]()
        oldarray?.append(json.rawString()!)
      }
      UserDefaults.standard.set(oldarray, forKey: key)
      UserDefaults.standard.synchronize()
    }
  }
  //收到通知推送消息
  static func pushNotificationMessages(_ msg:String){
    DispatchQueue.main.async{
      print("收到通知")
      let dic = ["msg":msg,"state":2] as [String : Any];
      NotificationCenter.default.post(name: Notification.Name(rawValue: "NotificationIdentifier"), object: dic)
    }
  }
  //change消息
  func stateChange(_ msg:String, state:Int){
      print("swift收到stateChange消息")
      let dic = ["msg":msg,"state":state] as [String : Any];
      NotificationCenter.default.post(name: Notification.Name(rawValue: "NotificationIdentifier"), object: dic)
  }
  //消息回调
  func getMyName(_ notification:Notification){
    let state = (notification.object as AnyObject).value(forKey: "state") as? Int
    let msg = (notification.object as AnyObject).value(forKey: "msg") as? String
    self.event_penetrate_msg(msg!,state:state!)
  }
  
  //发送消息  1透传 2通知 3change
  func event_penetrate_msg(_ msg:String,state:Int){
    if state == 1{
      //发送透传消息
      self.sendEvent(withName: "PenetrateEvent", body: msg)
    }else if state == 2{
      //发送通知消息
      self.sendEvent(withName: "PushEvent",body: msg)
    }else{
      //state change消息
      self.sendEvent(withName: "PushStateEvent",body: msg)
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
      BPush.bindChannel(completeHandler:{(result:Any?, error:Error?) in
        if error != nil{
          callback(["error_code":"-2"])
          return
        }
        var ret:Dictionary = ["error_code":"-1"]
        //let channel_id = (result as AnyObject).object(forKey:"channel_id") as! String
        if let channel_id = JSON(result!)["channel_id"].string {
          ret=[
            "error_code":"0",
            "msgState":"1",
            "channel_id":channel_id,
            "app_id":JSON(result!)["app_id"].string!,
          ]
          print("绑定成功")
        }
        self.stateChange(JSON(ret).rawString()!,state: 3)
      } )
    }
  }
  
  //解除绑定Push服务通道
  @objc func unbindChannelWithCompleteHandler(_ callback: @escaping ([String:String]) -> ()){
    DispatchQueue.main.async{
      //let callback1:BPushCallBack = {}
      BPush.unbindChannel (completeHandler:{(result:Any?, error:Error?) in
        var ret = ["error_code":"-1","msgState":"2",]
        // 确认是否解绑绑定成功
        //let request_id = (result as AnyObject).object(forKey:"request_id")
        if let request_id = JSON(result!)["request_id"].string {
          print("解绑成功 request_id=\(request_id)")
          ret = ["error_code":"0","msgState":"2",]
        }else{
          print("解绑failed")
        }
        self.stateChange(JSON(ret).rawString()!,state: 3)
      })
    }
  }
  
  //设置tags
  @objc func setTag(_ tags:String,callback: @escaping ([String:String]) -> ()){
    DispatchQueue.main.async{
      var ret = ["error_code":"-1","msgState":"3",]
      //let callback1:BPushCallBack = {}
      BPush.setTag(tags, withCompleteHandler: { (result:Any?, error:Error?) in
        // 确认是否设置成功
        //let error_code = (result as AnyObject).object(forKey:"error_code") as! String
        if let error_code = JSON(result!)["error_code"].string{
          ret = ["error_code":error_code,"msgState":"3",]
          print("set tags error_code=\(error_code)")
          self.stateChange(JSON(ret).rawString()!,state: 3)
        } //else channel id is not number
      })
    }
  }
  
  //删除tags
  @objc func delTag(_ tags:String,callback: @escaping ([String:String]) -> ()){
    DispatchQueue.main.async{
      var ret = ["error_code":"-1","msgState":"4",]
      BPush.delTag(tags, withCompleteHandler: { (result:Any?, error:Error?) in
        // 确认是否删除成功
        //let error_code = (result as AnyObject).object(forKey:"error_code") as! String
        if let error_code = JSON(result!)["error_code"].string {
          ret = ["error_code":error_code,"msgState":"4",]
          print("tags 删除成功")
          self.stateChange(JSON(ret).rawString()!,state: 3)
        }
      })
    }
  }
  //list tags
  @objc func listTags(_ callback: @escaping ([String:String]) -> ()){
    DispatchQueue.main.async{
      BPush.listTags(completeHandler: {(result:Any?, error:Error?) in
        // 确认是否删除成功
        var ret = ["error_code":"-1","msgState":"5","tags":[]] as [String : Any]
        let tag_names = JSON(result!)["response_params"]["tags"].arrayValue.map({$0["name"].stringValue})
        print("swift layer tags listed:\(tag_names)")
        ret = ["error_code":"-1","msgState":"5","tags":tag_names]
        self.stateChange(JSON(ret).rawString()!,state: 3)
      })
    }
  }
}
