import Toybox.Lang;
import Toybox.WatchUi;

class TennisMatchDelegate extends WatchUi.BehaviorDelegate {
    var match as MatchState;
    var recorder as MatchRecorder; 

    function initialize(m as MatchState, r as MatchRecorder) {
        BehaviorDelegate.initialize();
        match = m;
        recorder = r; 
    }

    function onMenu() as Boolean {
        WatchUi.pushView(
            new Rez.Menus.MainMenu(),
            new TennisMatchMenuDelegate(),
            WatchUi.SLIDE_UP
        );
        return true;
    }

    function onPreviousPage() as Boolean {
        match.pointWon(ME);
        WatchUi.requestUpdate();
        return true;
    }

    function onNextPage() as Boolean {
        match.pointWon(OPPONENT);
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() as Boolean {
        if (!match.canUndo()) {
            return false;
        }

        match.undo();
        WatchUi.requestUpdate();
        return true;
    }
}
