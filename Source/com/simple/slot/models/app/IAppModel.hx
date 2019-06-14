package com.simple.slot.models.app;
import IBaseModel;
interface IAppModel extends IBaseModel extends IAppModelImmutable{
    function setIsTampering(value:Bool):IAppModel;
    function setBalance(value:Int):IAppModel;
    function setSpinCost(value:Int):IAppModel;
    function setLocked(value:Bool):IAppModel;
}