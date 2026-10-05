import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class PauseMenuDelegate extends WatchUi.Menu2InputDelegate {

    var recorder as MatchRecorder;

    function initialize(r as MatchRecorder) {
        Menu2InputDelegate.initialize();
        recorder = r;                                  // wie im TennisMatchDelegate
    }

    // Ein Menüeintrag wurde ausgewählt
    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        if (id == :resume) {
            recorder.start();                           // Aufzeichnung fortsetzen
            WatchUi.popView(WatchUi.SLIDE_DOWN);    // Menü schließen → Spielansicht
        } else if (id == :save) {
            recorder.save();                           // speichern
            System.exit();
        } else if (id == :discard) {
            recorder.discard();                             // verwerfen
            System.exit();                                  // App beenden
        }
    }

    // Zurück-Taste IM Menü = Fortsetzen
    function onBack() as Void {
        recorder.start(); 
        WatchUi.popView(WatchUi.SLIDE_DOWN); 
    }
}
