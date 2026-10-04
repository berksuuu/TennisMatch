import Toybox.Lang;
import Toybox.Test;

// Hilfsfunktion: `player` gewinnt `n` Punkte hintereinander
function winPoints(m as MatchState, player as Number, n as Number) as Void {
    for (var i = 0; i < n; i++) {
        m.pointWon(player);
    }
}

// 4 Punkte am Stück = 1 Game, Punkte werden zurückgesetzt
(:test)
function testGameAfterFourPoints(logger as Logger) as Boolean {
    var m = new MatchState();
    winPoints(m, ME, 4);
    Test.assertEqualMessage(m.games[ME], 1, "Games ich");
    Test.assertEqualMessage(m.points[ME], 0, "Punkte ich zurückgesetzt");
    return true;
}

// 3:3, dann Vorteil → noch kein Game; dann 2 Punkte → Game
(:test)
function testDeuceNeedsTwoPoints(logger as Logger) as Boolean {
    var m = new MatchState(); 
    winPoints(m, ME, 3); 
    winPoints(m, OPPONENT, 3); 
    winPoints(m, ME, 1); 
    Test.assertEqualMessage(m.games[ME], 0, "Bei Vorteil noch kein Game"); 
    winPoints(m, ME, 1); 
    Test.assertEqualMessage(m.games[ME], 1, "Game nach 2 Punkten Vorsprung"); 
    return true; 
}

(:test)
function testSetWonSixFour(logger as Logger) as Boolean {
    var m = new MatchState(); 
    winPoints(m, ME, 4*4);
    winPoints(m, OPPONENT, 4*4);
    winPoints(m, ME, 4*1);
    winPoints(m, ME, 4*1);
    Test.assertEqualMessage(m.sets[ME], 1, "Bei 6 Punkten Satz gewinn!"); 
    Test.assertEqualMessage(m.games[ME], 0, "Spiele werden zurückgesetzt"); 
    return true; 
}

(:test)
function testNoSetAtSixFive(logger as Logger) as Boolean {
    var m = new MatchState(); 
    winPoints(m, ME, 4*5); 
    winPoints(m, OPPONENT, 4*5); 
    winPoints(m, ME, 4*1);
    Test.assertEqualMessage(m.sets[ME], 0, "Bei 6 zu 5 kein Satz"); 
    Test.assertEqualMessage(m.games[ME], 6, "Break geht weiter"); 
    return true; 
}

(:test)
function testTiebreakStartsAtSixSix(logger as Logger) as Boolean {
    var m = new MatchState(); 
    winPoints(m, ME, 4*5); 
    winPoints(m, OPPONENT, 4*5);
    winPoints(m, ME, 4*1); 
    winPoints(m, OPPONENT, 4*1);
    Test.assertEqualMessage(m.tiebreak, true, "Tiebreak ");
    return true; 
}

function playToTiebreak(m as MatchState) as Void {
    winPoints(m, ME, 4*5);
    winPoints(m, OPPONENT, 4*5);
    winPoints(m, ME, 4*1);
    winPoints(m, OPPONENT, 4*1);
}

(:test)
function testTiebreakNeedsTwo(logger as Logger) as Boolean {
    var m = new MatchState();
    playToTiebreak(m);
    winPoints(m, ME, 6);
    winPoints(m, OPPONENT, 6);
    winPoints(m, ME, 1);
    Test.assertEqualMessage(m.points[ME], 7, "Tiebreak-Punkte ich");
    Test.assertEqualMessage(m.tiebreak, true, "Weiterhin Tiebreak");
    Test.assertEqualMessage(m.sets[ME], 0, "Kein Satzgewinn");
    return true;
}

// Tie-Break 8:6 → Satz gewonnen
(:test)
function testTiebreakWinsSet(logger as Logger) as Boolean {
    var m = new MatchState();
    playToTiebreak(m);
    winPoints(m, ME, 6);
    winPoints(m, OPPONENT, 6);
    winPoints(m, ME, 2);
    Test.assertEqualMessage(m.tiebreak, false, "Tiebreak vorbei");
    Test.assertEqualMessage(m.sets[ME], 1, "Tiebreak gewonnen");
    Test.assertEqualMessage(m.points[ME], 0, "Punkte zurückgesetzt");
    return true;
}

(:test)
function testMatchFinished(logger as Logger) as Boolean {
    var m = new MatchState(); 
    winPoints(m, ME, 4*6);
    winPoints(m, ME, 4*6);
    winPoints(m, OPPONENT, 4*4);
    Test.assertEqualMessage(m.finished, true, "Spiel ist vorbei");
    Test.assertEqualMessage(m.points[OPPONENT], 0, "Match Finished"); 
    return true; 
}

(:test)
function testServerAlternates(logger as Logger) as Boolean {
    var m = new MatchState();
    Test.assertEqualMessage(m.currentServer(), ME, "Spieler 1 schlägt auf"); 
    winPoints(m, ME, 4*1); 
    Test.assertEqualMessage(m.currentServer(), OPPONENT, "Spieler 2 schlägt auf"); 
    return true; 
}

// ---------- Undo ----------

// Undo nimmt genau einen Punkt zurück
(:test)
function testUndoPoint(logger as Logger) as Boolean {
    var m = new MatchState();
    winPoints(m, ME, 2);
    m.undo();
    Test.assertEqualMessage(m.points[ME], 1, "Punkte ich nach Undo");
    return true;
}

// Undo nach einem Game holt 40:0, das Game und den Aufschlag zurück
(:test)
function testUndoGame(logger as Logger) as Boolean {
    var m = new MatchState();
    winPoints(m, ME, 4);
    m.undo();
    Test.assertEqualMessage(m.games[ME], 0, "Game zurückgenommen");
    Test.assertEqualMessage(m.points[ME], 3, "wieder 40:0");
    Test.assertEqualMessage(m.currentServer(), ME, "Aufschlag wieder bei mir");
    return true;
}

// Undo nach einem Tie-Break-Gewinn holt den Tie-Break zurück
(:test)
function testUndoTiebreakWin(logger as Logger) as Boolean {
    var m = new MatchState();
    playToTiebreak(m);
    winPoints(m, ME, 7);
    Test.assertEqualMessage(m.sets[ME], 1, "Satz gewonnen");
    m.undo();
    Test.assertEqualMessage(m.sets[ME], 0, "Satz zurückgenommen");
    Test.assertEqualMessage(m.tiebreak, true, "wieder im Tie-Break");
    Test.assertEqualMessage(m.points[ME], 6, "wieder 6 Tie-Break-Punkte");
    return true;
}

// Undo im Tie-Break darf die Aufschlag-Reihenfolge nicht verdrehen
(:test)
function testUndoInTiebreakKeepsServer(logger as Logger) as Boolean {
    var m = new MatchState();
    playToTiebreak(m);                  // bei 6:6 schlage ich den ersten Tie-Break-Punkt auf
    winPoints(m, ME, 2);
    m.undo();                           // Stand 1:0 im Tie-Break
    Test.assertEqualMessage(m.currentServer(), OPPONENT, "bei 1:0 schlägt der Gegner auf");
    return true;
}

// Undo nach Matchende macht das Match wieder spielbar
(:test)
function testUndoAfterMatchEnd(logger as Logger) as Boolean {
    var m = new MatchState();
    winPoints(m, ME, 4*6*2);
    Test.assertEqualMessage(m.finished, true, "Match vorbei");
    m.undo();
    Test.assertEqualMessage(m.finished, false, "Match läuft wieder");
    Test.assertEqualMessage(m.sets[ME], 1, "nur noch 1 Satz");
    return true;
}

// Undo ohne gespielte Punkte: nichts passiert, kein Absturz
(:test)
function testUndoEmpty(logger as Logger) as Boolean {
    var m = new MatchState();
    Test.assertEqualMessage(m.canUndo(), false, "nichts zum Rückgängigmachen");
    m.undo();
    Test.assertEqualMessage(m.points[ME], 0, "Punkte unverändert");
    return true;
}

// Schnappschüsse sind echte Kopien (Falle: Arrays sind nur Verweise)
(:test)
function testSnapshotIsIndependent(logger as Logger) as Boolean {
    var m = new MatchState();
    winPoints(m, ME, 2);
    m.undo();
    m.undo();
    Test.assertEqualMessage(m.points[ME], 0, "zurück auf 0:0");
    Test.assertEqualMessage(m.canUndo(), false, "Stapel leer");
    return true;
}
