import Toybox.Lang;
import Toybox.Application; 

// Regeln und Darstellung für ein Match – werden vor dem Match festgelegt und ändern sich danach nicht
class MatchRules {

    var setsToWin as Number;        // 1 = Best of 1, 2 = Best of 3, 3 = Best of 5
    var noAd as Boolean;            // true = bei 40:40 entscheidet ein Punkt
    var matchTiebreak as Boolean;   // true = Entscheidungssatz ist ein Tie-Break bis 10
    var firstServer as Number;      // ME oder OPPONENT
    var theme as Number;            // Index in THEMES (siehe Theme.mc)

    // Standardregeln
    function initialize() {
        setsToWin = 2;
        noAd = false;
        matchTiebreak = false;
        firstServer = ME;
        theme = 0;
    }

    // Gemerkte Regeln laden (fehlt ein Wert, bleibt der Standard)
    function load() as Void {
        var sets = Application.Storage.getValue("setsToWin");
        if (sets != null) {
            setsToWin = sets as Number;
        }

        var ad = Application.Storage.getValue("noAd");
        if (ad != null) {
            noAd = ad as Boolean;
        }

        var tiebreak = Application.Storage.getValue("matchTiebreak");
        if (tiebreak != null) {
            matchTiebreak = tiebreak as Boolean;
        }

        var savedTheme = Application.Storage.getValue("theme");
        if (savedTheme != null && (savedTheme as Number) < THEME_COUNT) {
            theme = savedTheme as Number;
        }
    }

    // Aktuelle Regeln merken (den Aufschläger nicht – der wird vor jedem Match neu entschieden)
    function save() as Void {
        Application.Storage.setValue("setsToWin", setsToWin);
        Application.Storage.setValue("noAd", noAd);
        Application.Storage.setValue("matchTiebreak", matchTiebreak);
        Application.Storage.setValue("theme", theme);
    }
}
