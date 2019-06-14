package com.simple.slot.context;
import IPayTableModel;
import IPayTableModel;
import IPayTableModel;
import IAppModelImmutable;
import IAppModelImmutable;
import IAppModel;
import IAppModel;
import IAppModel;
import IReelsModel;
import IReelsModel;
import IReelsModel;
import IPayTableModelImmutable;
import IPayTableModelImmutable;
import IReelsModelImmutable;
import IReelsModelImmutable;
import IAppController;
import com.simple.slot.controller.AppController;
import com.simple.slot.controller.AppControllerEventType;
import com.simple.slot.models.app.AppModel;
import com.simple.slot.models.payTable.PayTableModel;
import com.simple.slot.models.reels.ReelsModel;
import com.simple.slot.view.AppView;
import com.simple.slot.view.AppViewEventType;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
class AppContext implements IAppContext {
    public var appModel(get, never):IAppModel;
    public var reelsModel(get, never):IReelsModel;
    public var payTableModel(get, never):IPayTableModel;

    public var appModelImmutable(get, never):IAppModelImmutable;
    public var reelsModelImmutable(get, never):IReelsModelImmutable;
    public var payTableModelImmutable(get, never):IPayTableModelImmutable;

    private var _appModel:IAppModel;
    private var _reelsModel:IReelsModel;
    private var _payTableModel:IPayTableModel;

    private var viewRoot:DisplayObjectContainer;

    private var controller:IAppController;

    private var view:AppView;

    public function new(viewRoot:DisplayObjectContainer) {
        this.viewRoot = viewRoot;

        init();
    }

    private function init():Void
    {
        _appModel = new AppModel();
        _reelsModel = new ReelsModel();
        _payTableModel = new PayTableModel();

        controller = new AppController(this);
        controller.addEventListener(AppControllerEventType.RESOURCES_LOADED, createViews);

        controller.loadResources();
    }

    private function createViews(event:Event):Void
    {
        view = new AppView(this, viewRoot);

        view.addEventListener(AppViewEventType.SPIN, function(e:Event):Void {
            controller.spin(view.fixedDataList);
        });

        view.addEventListener(AppViewEventType.REELS_STOPPED, function(e:Event):Void {
            controller.resultsShown();
        });

        view.addEventListener(AppViewEventType.CHANGE_BALANCE, function(e:Event):Void {
            controller.updateBalance(view.newBalanceValue);
        });

        view.addEventListener(AppViewEventType.CHANGE_SPIN_COST, function(e:Event):Void {
            controller.updateSpinCost(view.newSpinCostValue);
        });
    }

    function get_appModel():IAppModel {
        return _appModel;
    }

    function get_reelsModel():IReelsModel {
        return _reelsModel;
    }

    function get_payTableModel():IPayTableModel {
        return _payTableModel;
    }

    function get_appModelImmutable():IAppModelImmutable {
        return _appModel;
    }

    function get_reelsModelImmutable():IReelsModelImmutable {
        return _reelsModel;
    }

    function get_payTableModelImmutable():IPayTableModelImmutable {
        return _payTableModel;
    }
}