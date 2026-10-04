import Toybox.Lang;
import Toybox.WatchUi;

class TennisMatchDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new TennisMatchMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}