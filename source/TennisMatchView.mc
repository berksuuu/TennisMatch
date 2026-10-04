import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang; 
class TennisMatchView extends WatchUi.View {

    var match as MatchState; 

    function initialize(m as MatchState) {
        View.initialize();
        match = m; 
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
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
        var pointsText = match.points[ME].toString() + " - " + match.points[OPPONENT].toString();   
        dc.drawText(midX, midY, Graphics.FONT_LARGE, pointsText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);



    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
