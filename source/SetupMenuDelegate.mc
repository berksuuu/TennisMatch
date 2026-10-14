import Toybox.Lang;
import Toybox.WatchUi;

// Untertitel für "Sätze", z. B. "Best of 3"
function setsLabel(setsToWin as Number) as String {
    return tr(Rez.Strings.BestOf) + " " + (setsToWin * 2 - 1).toString();
}

// Untertitel für "Aufschlag"
function serverLabel(player as Number) as String {
    if (player == ME) {
        return tr(Rez.Strings.Me);
    }
    return tr(Rez.Strings.Opponent);
}

// Baut das Setup-Menü mit den aktuellen Regeln als Startwerten
function createSetupMenu(rules as MatchRules) as WatchUi.Menu2 {
    var menu = new WatchUi.Menu2({:title => tr(Rez.Strings.NewMatch)});
    menu.addItem(new WatchUi.MenuItem(tr(Rez.Strings.StartMatch), null, :start, null));
    menu.addItem(new WatchUi.MenuItem(tr(Rez.Strings.Sets), setsLabel(rules.setsToWin), :sets, null));
    menu.addItem(new WatchUi.ToggleMenuItem(tr(Rez.Strings.NoAd), null, :noAd, rules.noAd, null));
    menu.addItem(new WatchUi.ToggleMenuItem(tr(Rez.Strings.MatchTiebreak), null, :matchTiebreak, rules.matchTiebreak, null));
    menu.addItem(new WatchUi.MenuItem(tr(Rez.Strings.FirstServe), serverLabel(rules.firstServer), :server, null));
    menu.addItem(new WatchUi.MenuItem(tr(Rez.Strings.Theme), themeName(rules.theme), :theme, null));
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
            // Auswahl merken, Match mit diesen Regeln starten und das Setup durch die Spielansicht ersetzen
            rules.save();
            var match = new MatchState(rules);
            var recorder = new MatchRecorder();
            recorder.start();
            WatchUi.switchToView(new TennisMatchView(match), new TennisMatchDelegate(match, recorder), WatchUi.SLIDE_LEFT);

        } else if (id == :sets) {
            rules.setsToWin = rules.setsToWin % 3 + 1;          // 1 → 2 → 3 → 1
            item.setSubLabel(setsLabel(rules.setsToWin));

        } else if (id == :noAd) {
            rules.noAd = (item as WatchUi.ToggleMenuItem).isEnabled();

        } else if (id == :matchTiebreak) {
            rules.matchTiebreak = (item as WatchUi.ToggleMenuItem).isEnabled();

        } else if (id == :server) {
            rules.firstServer = 1 - rules.firstServer;
            item.setSubLabel(serverLabel(rules.firstServer));

        } else if (id == :theme) {
            rules.theme = (rules.theme + 1) % THEME_COUNT;
            item.setSubLabel(themeName(rules.theme));
        }
    }
}
