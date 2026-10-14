import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
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
        return true;
    }

    function onBack() as Boolean {
        if (!match.canUndo()) {
            openPauseMenu();
            return true;
        }

        match.undo();
        vibrate([new Attention.VibeProfile(30, 40)]);
        WatchUi.requestUpdate();
        return true;
    }

    // Antippen: linke Hälfte = Punkt für mich, rechte Hälfte = Punkt für den Gegner
    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        var x = evt.getCoordinates()[0];
        var width = System.getDeviceSettings().screenWidth;
        scorePoint(x < width / 2 ? ME : OPPONENT);
        return true;
    }

    // Wischen nach oben/unten ignorieren, damit nicht versehentlich Punkte vergeben werden
    function onSwipe(evt as WatchUi.SwipeEvent) as Boolean {
        var dir = evt.getDirection();
        return dir == WatchUi.SWIPE_UP || dir == WatchUi.SWIPE_DOWN;
    }

    // Aufzeichnung pausieren und Pausenmenü anzeigen
    private function openPauseMenu() as Void {
        recorder.pause();
        WatchUi.pushView(createPauseMenu(), new PauseMenuDelegate(recorder, true), WatchUi.SLIDE_UP);
    }

    // Punkt vergeben; bei Satzende neue Runde, passende Vibration, bei Matchende Zusammenfassung
    private function scorePoint(player as Number) as Void {
        if (match.finished) {
            return;
        }
        var setsBefore = match.sets[ME] + match.sets[OPPONENT];
        var gamesBefore = match.gamesPlayed;

        match.pointWon(player);

        var setEnded = match.sets[ME] + match.sets[OPPONENT] > setsBefore;
        if (setEnded) {
            recorder.addLap();
        }

        if (match.finished) {
            vibrate([new Attention.VibeProfile(100, 800)]);
            recorder.pause();
            WatchUi.pushView(new SummaryView(match), new SummaryDelegate(match, recorder), WatchUi.SLIDE_UP);
            return;
        }

        if (setEnded) {
            vibrate([
                new Attention.VibeProfile(80, 300),
                new Attention.VibeProfile(0, 150),
                new Attention.VibeProfile(80, 300)
            ]);
        } else if (match.changeover) {
            vibrate([
                new Attention.VibeProfile(80, 120),
                new Attention.VibeProfile(0, 100),
                new Attention.VibeProfile(80, 120),
                new Attention.VibeProfile(0, 100),
                new Attention.VibeProfile(80, 120)
            ]);
        } else if (match.gamesPlayed > gamesBefore) {
            vibrate([new Attention.VibeProfile(70, 250)]);
        } else {
            vibrate([new Attention.VibeProfile(50, 50)]);
        }

        WatchUi.requestUpdate();
    }

    // Vibrieren, sofern das Gerät es kann und Vibration in den Uhreinstellungen an ist
    private function vibrate(pattern as Array<Attention.VibeProfile>) as Void {
        if (Attention has :vibrate && System.getDeviceSettings().vibrateOn) {
            Attention.vibrate(pattern);
        }
    }
}
