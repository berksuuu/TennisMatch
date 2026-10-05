import Toybox.Lang;
import Toybox.WatchUi;

// Untertitel für "Sätze", z. B. "Best of 3"
function setsLabel(setsToWin as Number) as String {
    return "Best of " + ((setsToWin * 2) - 1).toString();          // Formel aus Theorie 5
}

// Untertitel für "Aufschlag"
function serverLabel(player as Number) as String {
    if (player == ME) {
        return "Ich";
    }
    return "Gegner";
}

// Baut das Setup-Menü mit den aktuellen Regeln als Startwerten
function createSetupMenu(rules as MatchRules) as WatchUi.Menu2 {
    var menu = new WatchUi.Menu2({:title => "Neues Match"});
    menu.addItem(new WatchUi.MenuItem("Match starten", null, :start, null));
    menu.addItem(new WatchUi.MenuItem("Sätze", setsLabel(rules.setsToWin), :sets, null));
    menu.addItem(new WatchUi.ToggleMenuItem("No-Ad", null, :noAd, rules.noAd, null));
    menu.addItem(new WatchUi.ToggleMenuItem("Match-Tie-Break", null, :matchTiebreak, rules.matchTiebreak, null));
    menu.addItem(new WatchUi.MenuItem("Aufschlag", serverLabel(rules.firstServer), :server, null));
    return menu;
}

class SetupMenuDelegate extends WatchUi.Menu2InputDelegate {

    var rules as MatchRules;

    function initialize(r as MatchRules) {
        Menu2InputDelegate.initialize();
        rules = r;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        if (id == :start) {
            // Match mit den gewählten Regeln erzeugen, Aufzeichnung starten
            rules.save();
            var match = new MatchState(rules);
            var recorder = new MatchRecorder();
            recorder.start();
            // Setup-Menü durch die Spielansicht ERSETZEN (Theorie 1)
            WatchUi.switchToView(new TennisMatchView(match), new TennisMatchDelegate(match, recorder), WatchUi.SLIDE_LEFT);

        } else if (id == :sets) {
            rules.setsToWin = rules.setsToWin % 3 + 1;                 // durchschalten (Theorie 4)
            item.setSubLabel(setsLabel(rules.setsToWin));                 // neuen Untertitel setzen

        } else if (id == :noAd) {
            rules.noAd = (item as WatchUi.ToggleMenuItem).isEnabled();

        } else if (id == :matchTiebreak) {
            rules.matchTiebreak = (item as WatchUi.ToggleMenuItem).isEnabled();                                    // genauso wie bei No-Ad

        } else if (id == :server) {
            rules.firstServer = 1 - rules.firstServer;               // Ich ↔ Gegner (der bekannte Trick)
            item.setSubLabel(serverLabel(rules.firstServer));
        }
    }
}
