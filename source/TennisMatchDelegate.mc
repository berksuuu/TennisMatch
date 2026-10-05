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

    function onSelect() as Boolean {
        openPauseMenu(); 
        return true; 
    }

    function onPreviousPage() as Boolean {
        scorePoint(ME);
        return true;
    }

    function onNextPage() as Boolean {
        scorePoint(OPPONENT);
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() as Boolean {
        if (!match.canUndo()) {
            openPauseMenu();
            return true;
        }

        match.undo();
        WatchUi.requestUpdate();
        return true;
    }

     // Aufzeichnung pausieren und Pausenmenü anzeigen
    private function openPauseMenu() as Void {
        recorder.pause();                               // pausieren

        var menu = new WatchUi.Menu2({:title => "Pause"});
        menu.addItem(new WatchUi.MenuItem("Fortsetzen", null, :resume, null));
        menu.addItem(new WatchUi.MenuItem("Speichern", null, :save, null));
        menu.addItem(new WatchUi.MenuItem("Verwerfen", null, :discard, null));

        WatchUi.pushView(menu, new PauseMenuDelegate(recorder), WatchUi.SLIDE_UP);
    }

        // Punkt vergeben; wenn dadurch ein Satz endet, neue Runde in der Aufzeichnung
    private function scorePoint(player as Number) as Void {
        var setsBefore = match.sets[ME] + match.sets[OPPONENT];   // ① Sätze vorher

        match.pointWon(player);                                   // ② Punkt vergeben

        var setsAfter = match.sets[ME] + match.sets[OPPONENT];    // ③ Sätze nachher
        if (setsAfter > setsBefore) {                             // ④ Satz gerade beendet?
            recorder.addLap();                                    //    → neue Runde
        }

        WatchUi.requestUpdate();                                  // ⑤ neu zeichnen
    }


}
