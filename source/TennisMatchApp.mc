import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TennisMatchApp extends Application.AppBase {


    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
       
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var match = new MatchState();
        var recorder = new MatchRecorder();
        recorder.start();

        var view = new TennisMatchView(match);
        return [view, new TennisMatchDelegate(match, recorder)];
    }

 }





function getApp() as TennisMatchApp {
    return Application.getApp() as TennisMatchApp;
}