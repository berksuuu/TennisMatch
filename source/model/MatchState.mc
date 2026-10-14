import Toybox.Lang;

const ME = 0;
const OPPONENT = 1;

class MatchState {

    var points as Array<Number>;
    var games as Array<Number>;
    var sets as Array<Number>;
    var finished as Boolean;
    var tiebreak as Boolean;
    var server as Number;
    var history as Array<MatchState>;
    var rules as MatchRules;
    var pointsWon as Array<Number>;          // alle gewonnenen Punkte im Match: [ich, Gegner]
    var setScores as Array<Array<Number>>;   // Ergebnis jedes beendeten Satzes, z. B. [[6, 4], [3, 6]]
    var gamesPlayed as Number;               // gespielte Games im ganzen Match (für den Seitenwechsel)
    var changeover as Boolean;               // nach dem letzten Punkt ist Seitenwechsel (gilt bis zum nächsten Punkt)

    function initialize(r as MatchRules) {
        rules = r;
        points = [0, 0];
        games = [0, 0];
        sets = [0, 0];
        finished = false;
        tiebreak = false;
        server = rules.firstServer;
        history = [];
        pointsWon = [0, 0];
        setScores = [];
        gamesPlayed = 0;
        changeover = false;
    }

    function pointWon(player as Number) as Void {
        if (finished) {
            return;
        }

        history.add(copy());
        changeover = false;
        var other = 1 - player;
        points[player] += 1;
        pointsWon[player] += 1;

        var needed = 4;
        var lead = 2;
        if (tiebreak) {
            needed = 7;
            if (matchTieBreakActive()) {
                needed = 10;
            }
        } else if (rules.noAd) {
            lead = 1;
        }

        if (points[player] >= needed && (points[player] - points[other]) >= lead) {
            gameWon(player);
        } else if (tiebreak) {
            // im Tie-Break wird alle 6 Punkte die Seite gewechselt
            var played = points[ME] + points[OPPONENT];
            changeover = (played % 6 == 0);
        }
    }

    function currentServer() as Number {
        if (!tiebreak) {
            return server;
        }

        var played = points[ME] + points[OPPONENT];
        var pos = played % 4;

        if (pos == 1 || pos == 2) {
            return 1 - server;
        }

        return server;
    }

    // Was bringt der nächste Punkt für `player`? :matchPoint, :setPoint, :breakPoint oder null
    function pointStatus(player as Number) as Symbol? {
        if (finished) {
            return null;
        }

        // auf einer Kopie ausprobieren, was passiert, wenn `player` den nächsten Punkt gewinnt
        var next = copy();
        next.pointWon(player);

        if (next.finished) {
            return :matchPoint;
        }
        if (next.sets[player] > sets[player]) {
            return :setPoint;
        }
        if (!tiebreak && next.games[player] > games[player] && player != server) {
            return :breakPoint;
        }
        return null;
    }

    private function gameWon(player as Number) as Void {
        var wasMatchTiebreak = tiebreak && matchTieBreakActive();
        var tiebreakScore = [points[ME], points[OPPONENT]];

        server = 1 - server;
        games[player] += 1;
        points = [0, 0];
        gamesPlayed += 1;
        // Seitenwechsel nach jedem ungeraden Game (über das ganze Match gezählt)
        changeover = (gamesPlayed % 2 == 1);
        var other = 1 - player;

        if (tiebreak) {
            tiebreak = false;
            if (wasMatchTiebreak) {
                setWon(player, tiebreakScore);           // Match-Tie-Break: Punkte als Satzergebnis, z. B. 10-8
            } else {
                setWon(player, [games[ME], games[OPPONENT]]);
            }
        } else if (games[player] >= 6 && (games[player] - games[other]) >= 2) {
            setWon(player, [games[ME], games[OPPONENT]]);
        } else if (games[player] >= 6 && games[other] >= 6) {
            tiebreak = true;
        }
    }

    private function setWon(player as Number, score as Array<Number>) as Void {
        sets[player] += 1;
        setScores.add(score);
        games = [0, 0];

        if (sets[player] >= rules.setsToWin) {
            finished = true;
            changeover = false;
        } else if (matchTieBreakActive()) {
            tiebreak = true;
        }
    }

    function matchTieBreakActive() as Boolean {
        var decider = rules.setsToWin - 1;
        return rules.matchTiebreak && rules.setsToWin > 1 && sets[ME] == decider && sets[OPPONENT] == decider;
    }

    private function copy() as MatchState {
        var c = new MatchState(rules);
        c.points = [points[ME], points[OPPONENT]];
        c.games = [games[ME], games[OPPONENT]];
        c.sets = [sets[ME], sets[OPPONENT]];
        c.finished = finished;
        c.tiebreak = tiebreak;
        c.server = server;
        c.pointsWon = [pointsWon[ME], pointsWon[OPPONENT]];
        // die einzelnen Satzergebnisse werden nie verändert, eine neue Liste reicht
        c.setScores = setScores.slice(0, setScores.size());
        c.gamesPlayed = gamesPlayed;
        return c;
    }

    function canUndo() as Boolean {
        return history.size() > 0;
    }

    function undo() as Void {
        if (!canUndo()) {
            return;
        }

        var last = history[history.size() - 1];
        history = history.slice(0, history.size() - 1);

        points = last.points;
        games = last.games;
        sets = last.sets;
        finished = last.finished;
        tiebreak = last.tiebreak;
        server = last.server;
        pointsWon = last.pointsWon;
        setScores = last.setScores;
        gamesPlayed = last.gamesPlayed;
        changeover = false;
    }
}
