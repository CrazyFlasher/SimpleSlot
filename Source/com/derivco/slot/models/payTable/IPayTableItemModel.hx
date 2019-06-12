package com.derivco.slot.models.payTable;
import com.derivco.slot.models.common.IBaseModel;
interface IPayTableItemModel extends IPayTableItemModelImmutable extends IBaseModel{
    function calculatePayout(lineSymbolList:Array<String>, lineId:String):Int;
}
