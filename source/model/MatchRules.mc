import Toybox.Lang;

// Regeln für ein Match – werden vor dem Match festgelegt und ändern sich danach nicht
class MatchRules {

    var setsToWin as Number;        // 1 = Best of 1, 2 = Best of 3, 3 = Best of 5
    var noAd as Boolean;            // true = bei 40:40 entscheidet ein Punkt
    var matchTiebreak as Boolean;   // true = Entscheidungssatz ist ein Tie-Break bis 10 (kommt in 3.3)
    var firstServer as Number;      // ME oder OPPONENT

    // Standardregeln
    function initialize() {
        setsToWin = 2;
        noAd = false;
        matchTiebreak = false;
        firstServer = ME;
    }
}
