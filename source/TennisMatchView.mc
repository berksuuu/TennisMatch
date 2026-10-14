import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

// Spielansicht: linke Hälfte = ich, rechte Hälfte = Gegner
class TennisMatchView extends WatchUi.View {

    var match as MatchState;
    var timer as Timer.Timer?;
    var heart as WatchUi.BitmapResource?;

    function initialize(m as MatchState) {
        View.initialize();
        match = m;
        timer = null;
        heart = null;
    }

    function onLayout(dc as Dc) as Void {
        heart = WatchUi.loadResource(Rez.Drawables.Heart) as WatchUi.BitmapResource;
    }

    // Timer nur laufen lassen, solange die Ansicht sichtbar ist
    function onShow() as Void {
        timer = new Timer.Timer();
        timer.start(method(:onTick), 1000, true);
    }

    function onTick() as Void {
        WatchUi.requestUpdate();
    }

    function onHide() as Void {
        if (timer != null) {
            timer.stop();
            timer = null;
        }
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var midX = w / 2;
        var midY = h / 2;
        var theme = match.rules.theme;

        // Hintergrund: zwei Hälften in den Theme-Farben
        dc.setColor(themeLeftColor(theme), themeLeftColor(theme));
        dc.fillRectangle(0, 0, midX, h);
        dc.setColor(themeRightColor(theme), themeRightColor(theme));
        dc.fillRectangle(midX, 0, w - midX, h);

        // oben: Laufzeit und Satzverlauf
        var info = Activity.getActivityInfo();
        var timeText = "0:00";
        if (info != null && info.timerTime != null) {
            timeText = formatDuration(info.timerTime as Number);
        }
        drawText(dc, midX, h * 13 / 100, Graphics.FONT_TINY, timeText, TEXT_COLOR);
        drawText(dc, midX, h * 23 / 100, Graphics.FONT_XTINY, setScoresText(match), MUTED_COLOR);

        if (match.finished) {
            var result = match.sets[ME] > match.sets[OPPONENT] ? tr(Rez.Strings.Won) : tr(Rez.Strings.Lost);
            drawText(dc, midX, midY, Graphics.FONT_LARGE, result, TEXT_COLOR);
        } else {
            drawPlayer(dc, ME, midX - w * 20 / 100, h);
            drawPlayer(dc, OPPONENT, midX + w * 20 / 100, h);
            drawServeBall(dc, w, midX, midY);
            drawBanner(dc, midX, h * 76 / 100);
        }

        drawHeartRate(dc, info, midX, h * 88 / 100);
    }

    // Games, Punkte und ggf. Breakball/Satzball/Matchball für eine Hälfte
    private function drawPlayer(dc as Dc, player as Number, x as Number, h as Number) as Void {
        drawText(dc, x, h * 35 / 100, Graphics.FONT_MEDIUM, match.games[player].toString(), TEXT_COLOR);
        drawText(dc, x, h / 2, Graphics.FONT_LARGE, pointLabel(player), TEXT_COLOR);

        var status = match.pointStatus(player);
        if (status != null) {
            drawText(dc, x, h * 63 / 100, Graphics.FONT_XTINY, statusText(status), BALL_COLOR);
        }
    }

    // Neongelber Ball auf der Seite des Aufschlägers, mit dunklem Rand für helle Themes
    private function drawServeBall(dc as Dc, w as Number, midX as Number, midY as Number) as Void {
        var offset = w * 39 / 100;
        var x = match.currentServer() == ME ? midX - offset : midX + offset;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, midY, 12);
        dc.setColor(BALL_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, midY, 10);
    }

    // Seitenwechsel als auffälliges Banner, sonst ggf. Hinweis auf (Match-)Tie-Break
    private function drawBanner(dc as Dc, midX as Number, y as Number) as Void {
        if (match.changeover) {
            var text = tr(Rez.Strings.Changeover);
            var font = Graphics.FONT_XTINY;
            var bw = dc.getTextWidthInPixels(text, font) + 24;
            var bh = dc.getFontHeight(font) + 8;
            dc.setColor(BALL_COLOR, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(midX - bw / 2, y - bh / 2, bw, bh, bh / 2);
            drawText(dc, midX, y, font, text, Graphics.COLOR_BLACK);
        } else if (match.tiebreak) {
            var label = match.matchTieBreakActive() ? tr(Rez.Strings.MatchTiebreak) : tr(Rez.Strings.Tiebreak);
            drawText(dc, midX, y, Graphics.FONT_XTINY, label, TEXT_COLOR);
        }
    }

    // Rotes Herz + Herzfrequenz, zusammen zentriert
    private function drawHeartRate(dc as Dc, info as Activity.Info?, midX as Number, y as Number) as Void {
        var hrText = "--";
        if (info != null && info.currentHeartRate != null) {
            hrText = (info.currentHeartRate as Number).toString();
        }
        hrText += " bpm";

        var font = Graphics.FONT_TINY;
        var gap = 6;
        var iconW = 0;
        var iconH = 0;
        var icon = heart;
        if (icon != null) {
            iconW = icon.getWidth();
            iconH = icon.getHeight();
        }
        var total = iconW + gap + dc.getTextWidthInPixels(hrText, font);
        var x = midX - total / 2;

        if (icon != null) {
            dc.drawBitmap(x, y - iconH / 2, icon);
        }
        dc.setColor(TEXT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + iconW + gap, y, font, hrText, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Punktestand eines Spielers: 0/15/30/40/AD, im Tie-Break als Zahl
    private function pointLabel(player as Number) as String {
        var mine = match.points[player];
        var theirs = match.points[1 - player];

        if (match.tiebreak) {
            return mine.toString();
        }
        if (mine >= 3 && theirs >= 3) {
            return mine > theirs ? "AD" : "40";
        }
        var labels = ["0", "15", "30", "40"];
        return labels[mine];
    }

    private function statusText(status as Symbol) as String {
        if (status == :matchPoint) {
            return tr(Rez.Strings.MatchPoint);
        } else if (status == :setPoint) {
            return tr(Rez.Strings.SetPoint);
        }
        return tr(Rez.Strings.BreakPoint);
    }

    private function drawText(dc as Dc, x as Number, y as Number, font as Graphics.FontType, text as String, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
