/**
 * Created by qiepeipei on 16/8/15.
 */
'use strict';
import React, { PropTypes, Component } from 'react';
import {
    DeviceEventEmitter,
    NativeEventEmitter,
    NativeModules,
    Platform,
} from 'react-native'

var PushObj = NativeModules.BaiDuPush;

class Push{

    constructor (event) {
        //透传对象
        this.penetrate = {};
        //通知对象
        this.pushs = {};
        //状态对象
        this.statePush = {};
        if(Platform.OS==='ios'){
          //DeviceEventEmitter.addListener( 'PenetrateEvent', this._PenetrateEvent.bind(this) );
          //DeviceEventEmitter.addListener( 'PushEvent', this._PushEvent.bind(this) );
          //DeviceEventEmitter.addListener( 'PushStateEvent',this._PushStateEvent.bind(this));
          const PushModuleEvt = new NativeEventEmitter(PushObj)
          PushModuleEvt.addListener( 'PenetrateEvent', this._PenetrateEvent.bind(this) )
          PushModuleEvt.addListener( 'PushEvent', this._PushEvent.bind(this) );
          PushModuleEvt.addListener( 'PushStateEvent',this._PushStateEvent.bind(this));
          PushObj.bindChannelWithCompleteHandler(event);
        }else{
          DeviceEventEmitter.addListener( 'PenetrateEvent', this._PenetrateEvent.bind(this) );
          DeviceEventEmitter.addListener( 'PushEvent', this._PushEvent.bind(this) );
          DeviceEventEmitter.addListener( 'PushStateEvent',this._PushStateEvent.bind(this));
          PushObj.initialise();
        }
        this.statePush['init'] = event;
    }

    //状态回调
    _PushStateEvent(event){
        let json=event
        if(typeof json==='string') json=JSON.parse(event)
        //console.log('bdpush index.js _PushStateEvent() -- msgState='+json.msgState+'\njson='+json)
        //启动推送
        if(json['msgState'] == 1){
            this.statePush['init'](json);
        //停止推送
        }else if(json['msgState'] == 2){
            this.statePush['uninit'](json);
        //设置tag
        }else if(json['msgState'] == 3){
            this.statePush['setTag'](json);
        //删除tag
        }else if(json['msgState'] == 4){
            this.statePush['delTag'](json);
        //全部tags
        }else if(json['msgState'] == 5){
            this.statePush['listTags'](json);
        }
    }

    //透传消息回调
    _PenetrateEvent(event){
        this.penetrate(event);
    }
    //通知消息回调
    _PushEvent(event){
        this.pushs(event);
    }
    //接收透传消息
    penetrateEvent(event){
        this.penetrate = event;
    }
    //接收通知消息
    pushEvent(event){
        this.pushs = event;
    }
    //恢复推送
    bindChannelWithCompleteHandler(event){
        //初始化推送
        this.statePush['init'] = event;
        if (Platform.OS === 'android') {
            PushObj.resumeWork();
        }else{
            PushObj.bindChannelWithCompleteHandler(event);
        }
    }

    //停止推送
    unbindChannelWithCompleteHandler(event){
        this.statePush['uninit'] = event;
        if (Platform.OS === 'android') {
            PushObj.stopWork();
        }else{
            PushObj.unbindChannelWithCompleteHandler(event);
        }
    }

    //设置tags
    setTag(tags,event) {
        this.statePush['setTag'] = event;
        if (Platform.OS === 'android') {
            PushObj.setTags(tags);
        }else{
            PushObj.setTag(tags, event)
        }
    }

    //删除tags
    delTag(tags,event) {
        this.statePush['delTag'] = event;
        if (Platform.OS === 'android') {
            PushObj.delTags(tags);
        }else{
            PushObj.delTag(tags, event)
        }
    }
    //全部tags
    listTags(event){
        this.statePush['listTags'] = event;
        if (Platform.OS === 'android') {
            PushObj.listTags();
        }else{
            PushObj.listTags(event)
        }
    }
}

module.exports = Push;
