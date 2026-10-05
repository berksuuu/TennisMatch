import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang; 
import Toybox.Activity;
import Toybox.Timer; 

class TennisMatchView extends WatchUi.View {

    var match as MatchState; 
    var timer as Timer.Timer?; 

    function initialize(m as MatchState) {
        View.initialize();
        match = m; 
        timer = null; 

    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        timer = new Timer.Timer(); 
        timer.start(method(:onTick), 1000, true); 
    }

    function onTick() as Void {
        WatchUi.requestUpdate(); 
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK); 
        dc.clear(); 
        
        var midX = dc.getWidth() / 2; 
        var midY = dc.getHeight() / 2; 
        
                // Games klein, oberhalb der Mitte
        var gamesText = match.games[ME].toString() + " - " + match.games[OPPONENT].toString();
        dc.drawText(midX, midY - 90, Graphics.FONT_SMALL, gamesText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Punkte groß in der Mitte
        var scoreText; 
        if(match.finished) {
            if(match.sets[ME] > match.sets[OPPONENT]){
                scoreText = "Sieg!"; 
            } else {
                scoreText = "Niederlage!";
            }

        } else {
            scoreText = pointsText(); 
        }
        dc.drawText(midX, midY, Graphics.FONT_LARGE, scoreText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var setsText = "Sätze " + match.sets[ME].toString() + " - " + match.sets[OPPONENT].toString();   // wie gamesText, nur mit sets
        dc.drawText(midX, midY + 90, Graphics.FONT_SMALL, setsText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Aufschlag-Punkt (zuletzt, damit die gelbe Farbe nichts anderes einfärbt)
        if(!match.finished) {
            var dotX = midX - 130;
            if (match.currentServer() == OPPONENT) {
                dotX = midX + 130;
            }
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(dotX, midY, 8);
        }

        var timeText = "0:00";         
        var hrText = "--";

        var info = Activity.getActivityInfo();
        if (info != null) {
            var ms = info.timerTime;
            if (ms != null) {                                             
                var seconds = ms / 1000 ;                                 
                timeText = (seconds / 60).toString() 
                + ":" 
                + (seconds & 60).format("%02d");   
            }

            var hr = info.currentHeartRate;
            if (hr != null) {
                hrText = hr.toString();                                      
            }
        }

        dc.drawText(midX, midY - 140, Graphics.FONT_TINY, timeText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(midX, midY + 140, Graphics.FONT_TINY, hrText + " bpm", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    }

    private function pointsText() as String {
        var myself = match.points[ME]; 
        var opp = match.points[OPPONENT]; 

        if(match.tiebreak == true){
            return myself.toString() + " - " + opp.toString(); 
        }

        if (myself >= 3 && opp >= 3){
            if(myself == opp){
                return "40 - 40"; 
            } else if (myself > opp) {
                return "AD - 40"; 
            } else {
                return "40 - AD"; 
            }
        }

        var labels = ["0", "15", "30", "40"]; 

        return labels[myself] + " - " + labels[opp]; 

    }




    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        if(timer != null) {
            timer.stop(); 
            timer = null; 
        }
    }

}
