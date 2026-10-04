import Toybox.Lang;
import Toybox.WatchUi;

class TennisMatchDelegate extends WatchUi.BehaviorDelegate {

    var view as TennisMatchView;

    function initialize(v as TennisMatchView) {
        BehaviorDelegate.initialize();
        view = v;
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new TennisMatchMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onPreviousPage() as Boolean {
        view.count++; 
        WatchUi.requestUpdate();
        return true;
    }

     function onNextPage() as Boolean {
        view.count--; 
        WatchUi.requestUpdate();
        return true;
    }


}