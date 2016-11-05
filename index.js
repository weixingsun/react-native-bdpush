/**
 * Created by qiepeipei on 16/8/15.
 */
'use strict';
import React, { PropTypes, Component } from 'react';
import {
    DeviceEventEmitter,
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
        //接收 透传消息事件
        DeviceEventEmitter.addListener(
            'PenetrateEvent', this._PenetrateEvent.bind(this)
        );
        //接收 通知消息事件
        DeviceEventEmitter.addListener(
            'PushEvent', this._PushEvent.bind(this)
        );
        //接收操作状态
        DeviceEventEmitter.addListener(
            'PushStateEvent',this._PushStateEvent.bind(this));
        //初始化推送
        if (Platform.OS === 'android') {
            this.statePush['init'] = event;
            PushObj.initialise();
        }else{
            PushObj.bindChannelWithCompleteHandler(event);
        }
    }

    //状态回调
    _PushStateEvent(event){
        //alert('_PushStateEvent()'+JSON.stringify(event))
        //启动推送
        if(event['msgState'] == 1){
            this.statePush['init'](event);
        //停止推送
        }else if(event['msgState'] == 2){
            this.statePush['uninit'](event);
        //设置tag
        }else if(event['msgState'] == 3){
            this.statePush['setTag'](event);
        //删除tag
        }else if(event['msgState'] == 4){
            this.statePush['delTag'](event);
        //全部tags
        }else if(event['msgState'] == 5){
            this.statePush['listTags'](event);
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
        if (Platform.OS === 'android') {
            this.statePush['init'] = event;
            PushObj.resumeWork();
        }else{
            PushObj.bindChannelWithCompleteHandler(event);
        }
    }

    //停止推送
    unbindChannelWithCompleteHandler(event){
        if (Platform.OS === 'android') {
            this.statePush['uninit'] = event;
            PushObj.stopWork();
        }else{
            PushObj.unbindChannelWithCompleteHandler(event);
        }
    }

    //设置tags
    setTag(tags,event) {
        if (Platform.OS === 'android') {
            this.statePush['setTag'] = event;
            PushObj.setTags(tags);
        }else{
            PushObj.setTag(tags, event)
        }
    }

    //删除tags
    delTag(tags,event) {
        if (Platform.OS === 'android') {
            this.statePush['delTag'] = event;
            PushObj.delTags(tags);
        }else{
            PushObj.delTag(tags, event)
        }
    }
    //全部tags
    listTags(event){
        if (Platform.OS === 'android') {
            this.statePush['listTags'] = event;
            PushObj.listTags();
        }else{
            PushObj.listTags(event)
        }
    }
}

module.exports = Push;
