import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Zusammenfassung nach Matchende: Ergebnis, Sätze, Dauer, Puls, Kalorien, Punkte
class SummaryView extends WatchUi.View {

    var match as MatchState;

    function initialize(m as MatchState) {
        View.initialize();
        match = m;
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var midX = w / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var won = match.sets[ME] > match.sets[OPPONENT];
        var title = won ? tr(Rez.Strings.Won) : tr(Rez.Strings.Lost);
        drawText(dc, midX, h * 16 / 100, Graphics.FONT_MEDIUM, title, won ? BALL_COLOR : TEXT_COLOR);
        drawText(dc, midX, h * 28 / 100, Graphics.FONT_SMALL, setScoresText(match), TEXT_COLOR);

        var duration = "--";
        var avgHr = "--";
        var calories = "--";
        var info = Activity.getActivityInfo();
        if (info != null) {
            if (info.timerTime != null) {
                duration = formatDuration(info.timerTime as Number);
            }
            if (info.averageHeartRate != null) {
                avgHr = (info.averageHeartRate as Number).toString();
            }
            if (info.calories != null) {
                calories = (info.calories as Number).toString();
            }
        }
        var pointsText = match.pointsWon[ME].toString() + " - " + match.pointsWon[OPPONENT].toString();

        var font = Graphics.FONT_TINY;
        drawText(dc, midX, h * 40 / 100, font, tr(Rez.Strings.Duration) + "  " + duration, TEXT_COLOR);
        drawText(dc, midX, h * 50 / 100, font, tr(Rez.Strings.AvgHeartRate) + "  " + avgHr, TEXT_COLOR);
        drawText(dc, midX, h * 60 / 100, font, tr(Rez.Strings.Calories) + "  " + calories, TEXT_COLOR);
        drawText(dc, midX, h * 70 / 100, font, tr(Rez.Strings.PointsWon) + "  " + pointsText, TEXT_COLOR);

        drawText(dc, midX, h * 82 / 100, Graphics.FONT_XTINY, tr(Rez.Strings.SummaryHint), MUTED_COLOR);
    }

    private function drawText(dc as Dc, x as Number, y as Number, font as Graphics.FontType, text as String, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

// START: Match beenden (Speichern/Verwerfen), ZURÜCK: letzten Punkt zurücknehmen und weiterspielen
class SummaryDelegate extends WatchUi.BehaviorDelegate {

    var match as MatchState;
    var recorder as MatchRecorder;

    function initialize(m as MatchState, r as MatchRecorder) {
        BehaviorDelegate.initialize();
        match = m;
        recorder = r;
    }

    function onSelect() as Boolean {
        WatchUi.pushView(createEndMenu(), new PauseMenuDelegate(recorder, false), WatchUi.SLIDE_UP);
        return true;
    }

    function onBack() as Boolean {
        match.undo();
        recorder.start();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
