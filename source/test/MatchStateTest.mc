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
    var m = new MatchState(new MatchRules());
    winPoints(m, ME, 4);
    Test.assertEqualMessage(m.games[ME], 1, "Games ich");
    Test.assertEqualMessage(m.points[ME], 0, "Punkte ich zurückgesetzt");
    return true;
}

// 3:3, dann Vorteil → noch kein Game; dann 2 Punkte → Game
(:test)
function testDeuceNeedsTwoPoints(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules()); 
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
    var m = new MatchState(new MatchRules()); 
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
    var m = new MatchState(new MatchRules()); 
    winPoints(m, ME, 4*5); 
    winPoints(m, OPPONENT, 4*5); 
    winPoints(m, ME, 4*1);
    Test.assertEqualMessage(m.sets[ME], 0, "Bei 6 zu 5 kein Satz"); 
    Test.assertEqualMessage(m.games[ME], 6, "Break geht weiter"); 
    return true; 
}

(:test)
function testTiebreakStartsAtSixSix(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules()); 
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
    var m = new MatchState(new MatchRules());
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
    var m = new MatchState(new MatchRules());
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
    var m = new MatchState(new MatchRules()); 
    winPoints(m, ME, 4*6);
    winPoints(m, ME, 4*6);
    winPoints(m, OPPONENT, 4*4);
    Test.assertEqualMessage(m.finished, true, "Spiel ist vorbei");
    Test.assertEqualMessage(m.points[OPPONENT], 0, "Match Finished"); 
    return true; 
}

(:test)
function testServerAlternates(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    Test.assertEqualMessage(m.currentServer(), ME, "Spieler 1 schlägt auf"); 
    winPoints(m, ME, 4*1); 
    Test.assertEqualMessage(m.currentServer(), OPPONENT, "Spieler 2 schlägt auf"); 
    return true; 
}

// ---------- Undo ----------

// Undo nimmt genau einen Punkt zurück
(:test)
function testUndoPoint(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    winPoints(m, ME, 2);
    m.undo();
    Test.assertEqualMessage(m.points[ME], 1, "Punkte ich nach Undo");
    return true;
}

// Undo nach einem Game holt 40:0, das Game und den Aufschlag zurück
(:test)
function testUndoGame(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
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
    var m = new MatchState(new MatchRules());
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
    var m = new MatchState(new MatchRules());
    playToTiebreak(m);                  // bei 6:6 schlage ich den ersten Tie-Break-Punkt auf
    winPoints(m, ME, 2);
    m.undo();                           // Stand 1:0 im Tie-Break
    Test.assertEqualMessage(m.currentServer(), OPPONENT, "bei 1:0 schlägt der Gegner auf");
    return true;
}

// Undo nach Matchende macht das Match wieder spielbar
(:test)
function testUndoAfterMatchEnd(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
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
    var m = new MatchState(new MatchRules());
    Test.assertEqualMessage(m.canUndo(), false, "nichts zum Rückgängigmachen");
    m.undo();
    Test.assertEqualMessage(m.points[ME], 0, "Punkte unverändert");
    return true;
}

// Schnappschüsse sind echte Kopien (Falle: Arrays sind nur Verweise)
(:test)
function testSnapshotIsIndependent(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    winPoints(m, ME, 2);
    m.undo();
    m.undo();
    Test.assertEqualMessage(m.points[ME], 0, "zurück auf 0:0");
    Test.assertEqualMessage(m.canUndo(), false, "Stapel leer");
    return true;
}


// ---------- Regeln (MatchRules) ----------

// No-Ad: bei 40:40 entscheidet ein einziger Punkt
(:test)
function testNoAdDecidingPoint(logger as Logger) as Boolean {
    var rules = new MatchRules();
    rules.noAd = true;
    var m = new MatchState(rules);
    winPoints(m, ME, 3);
    winPoints(m, OPPONENT, 3);                 // 40:40
    winPoints(m, ME, 1);                       // entscheidender Punkt
    Test.assertEqualMessage(m.games[ME], 1, "Game nach einem Punkt bei 40:40");
    return true;
}

// No-Ad gilt nicht im Tie-Break: 7:6 reicht dort weiterhin nicht
(:test)
function testNoAdTiebreakStillNeedsTwo(logger as Logger) as Boolean {
    var rules = new MatchRules();
    rules.noAd = true;
    var m = new MatchState(rules);
    playToTiebreak(m);
    winPoints(m, ME, 6);
    winPoints(m, OPPONENT, 6);
    winPoints(m, ME, 1);                       // 7:6 im Tie-Break
    Test.assertEqualMessage(m.tiebreak, true, "Tie-Break läuft weiter");
    Test.assertEqualMessage(m.sets[ME], 0, "noch kein Satz");
    return true;
}

// Best of 1: ein Satz entscheidet das Match
(:test)
function testBestOfOne(logger as Logger) as Boolean {
    var rules = new MatchRules();
    rules.setsToWin = 1;
    var m = new MatchState(rules);
    winPoints(m, ME, 4*6);
    Test.assertEqualMessage(m.finished, true, "Match nach 1 Satz vorbei");
    return true;
}

// Best of 5: erst 3 Sätze entscheiden das Match
(:test)
function testBestOfFive(logger as Logger) as Boolean {
    var rules = new MatchRules();
    rules.setsToWin = 3;
    var m = new MatchState(rules);
    winPoints(m, ME, 4*6*2);
    Test.assertEqualMessage(m.finished, false, "nach 2 Sätzen noch nicht vorbei");
    winPoints(m, ME, 4*6);
    Test.assertEqualMessage(m.finished, true, "nach 3 Sätzen vorbei");
    return true;
}

// Gegner schlägt zuerst auf
(:test)
function testOpponentServesFirst(logger as Logger) as Boolean {
    var rules = new MatchRules();
    rules.firstServer = OPPONENT;
    var m = new MatchState(rules);
    Test.assertEqualMessage(m.currentServer(), OPPONENT, "Gegner schlägt zuerst auf");
    winPoints(m, ME, 4);
    Test.assertEqualMessage(m.currentServer(), ME, "nach einem Game ich");
    return true;
}



// ---------- Match-Tie-Break ----------

// Hilfsfunktion: Match mit Match-Tie-Break (Best of 3)
function newMatchTiebreakMatch() as MatchState {
    var rules = new MatchRules();
    rules.matchTiebreak = true;
    return new MatchState(rules);
}

// Bei 1:1 Sätzen beginnt sofort der Match-Tie-Break, gespielt bis 10
(:test)
function testMatchTiebreakToTen(logger as Logger) as Boolean {
    var m = newMatchTiebreakMatch();
    winPoints(m, ME, 4*6);
    winPoints(m, OPPONENT, 4*6);                       // 1:1 Sätze
    Test.assertEqualMessage(m.tiebreak, true, "Match-Tie-Break beginnt sofort");
    winPoints(m, ME, 7);
    Test.assertEqualMessage(m.finished, false, "7 Punkte reichen nicht");
    winPoints(m, ME, 3);
    Test.assertEqualMessage(m.finished, true, "bei 10 Punkten gewonnen");
    return true;
}

// Auch im Match-Tie-Break: 2 Punkte Vorsprung
(:test)
function testMatchTiebreakNeedsTwo(logger as Logger) as Boolean {
    var m = newMatchTiebreakMatch();
    winPoints(m, ME, 4*6);
    winPoints(m, OPPONENT, 4*6);
    winPoints(m, ME, 9);
    winPoints(m, OPPONENT, 9);
    winPoints(m, ME, 1);                               // 10:9
    Test.assertEqualMessage(m.finished, false, "10:9 reicht nicht");
    winPoints(m, ME, 1);                               // 11:9
    Test.assertEqualMessage(m.finished, true, "11:9 gewonnen");
    return true;
}

// Im ersten Satz bleibt der normale Tie-Break bis 7
(:test)
function testNormalTiebreakInFirstSet(logger as Logger) as Boolean {
    var m = newMatchTiebreakMatch();
    playToTiebreak(m);
    winPoints(m, ME, 7);
    Test.assertEqualMessage(m.sets[ME], 1, "Tie-Break bis 7 im ersten Satz");
    return true;
}

// Best of 1 mit Match-Tie-Break: normales Match, kein Tie-Break bei 0:0
(:test)
function testMatchTiebreakIgnoredInBestOfOne(logger as Logger) as Boolean {
    var rules = new MatchRules();
    rules.matchTiebreak = true;
    rules.setsToWin = 1;
    var m = new MatchState(rules);
    Test.assertEqualMessage(m.tiebreak, false, "normaler Start");
    playToTiebreak(m);
    winPoints(m, ME, 7);
    Test.assertEqualMessage(m.finished, true, "normaler Tie-Break bis 7 entscheidet");
    return true;
}


// ---------- Satzverlauf, Punkte, Seitenwechsel, Break-/Satz-/Matchball ----------

// Beendete Sätze werden mit Ergebnis gespeichert
(:test)
function testSetScoresRecorded(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    winPoints(m, OPPONENT, 4*4);
    winPoints(m, ME, 4*6);                             // 6:4
    Test.assertEqualMessage(m.setScores.size(), 1, "ein Satz gespeichert");
    Test.assertEqualMessage(m.setScores[0][ME], 6, "Satz 1 ich");
    Test.assertEqualMessage(m.setScores[0][OPPONENT], 4, "Satz 1 Gegner");
    return true;
}

// Tie-Break-Satz wird als 7:6 gespeichert
(:test)
function testTiebreakSetRecordedAsSevenSix(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    playToTiebreak(m);
    winPoints(m, ME, 7);
    Test.assertEqualMessage(m.setScores[0][ME], 7, "7 Games ich");
    Test.assertEqualMessage(m.setScores[0][OPPONENT], 6, "6 Games Gegner");
    return true;
}

// Match-Tie-Break wird mit seinen Punkten gespeichert, z. B. 10:8
(:test)
function testMatchTiebreakRecordedWithPoints(logger as Logger) as Boolean {
    var m = newMatchTiebreakMatch();
    winPoints(m, ME, 4*6);
    winPoints(m, OPPONENT, 4*6);
    winPoints(m, OPPONENT, 8);
    winPoints(m, ME, 10);                              // 10:8 → Match vorbei
    Test.assertEqualMessage(m.finished, true, "Match vorbei");
    Test.assertEqualMessage(m.setScores[2][ME], 10, "Match-Tie-Break ich");
    Test.assertEqualMessage(m.setScores[2][OPPONENT], 8, "Match-Tie-Break Gegner");
    return true;
}

// Gewonnene Punkte werden über das ganze Match gezählt
(:test)
function testPointsWonCounted(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    winPoints(m, ME, 5);
    winPoints(m, OPPONENT, 3);
    Test.assertEqualMessage(m.pointsWon[ME], 5, "Punkte ich");
    Test.assertEqualMessage(m.pointsWon[OPPONENT], 3, "Punkte Gegner");
    return true;
}

// Seitenwechsel nach dem 1. und 3. Game, nicht nach dem 2.
(:test)
function testChangeoverAfterOddGames(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    winPoints(m, ME, 3);
    Test.assertEqualMessage(m.changeover, false, "mitten im Game kein Wechsel");
    winPoints(m, ME, 1);
    Test.assertEqualMessage(m.changeover, true, "nach Game 1 Wechsel");
    winPoints(m, ME, 1);
    Test.assertEqualMessage(m.changeover, false, "Hinweis verschwindet beim nächsten Punkt");
    winPoints(m, ME, 3);
    Test.assertEqualMessage(m.changeover, false, "nach Game 2 kein Wechsel");
    winPoints(m, ME, 4);
    Test.assertEqualMessage(m.changeover, true, "nach Game 3 Wechsel");
    return true;
}

// Im Tie-Break alle 6 Punkte Seitenwechsel
(:test)
function testChangeoverEverySixTiebreakPoints(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    playToTiebreak(m);                                 // 12 Games gespielt → kein Wechsel
    winPoints(m, ME, 3);
    winPoints(m, OPPONENT, 2);
    Test.assertEqualMessage(m.changeover, false, "nach 5 Punkten kein Wechsel");
    winPoints(m, OPPONENT, 1);
    Test.assertEqualMessage(m.changeover, true, "nach 6 Punkten Wechsel");
    return true;
}

// Breakball: Rückschläger hat Spielball
(:test)
function testBreakPoint(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());          // ich schlage auf
    winPoints(m, OPPONENT, 3);                         // 0:40
    Test.assertEqualMessage(m.pointStatus(OPPONENT), :breakPoint, "Breakball Gegner");
    Test.assertEqualMessage(m.pointStatus(ME) == null, true, "für mich nichts");
    return true;
}

// Spielball des Aufschlägers ist kein Breakball
(:test)
function testServerGamePointIsNoBreakPoint(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    winPoints(m, ME, 3);                               // 40:0 bei eigenem Aufschlag
    Test.assertEqualMessage(m.pointStatus(ME) == null, true, "kein Breakball");
    return true;
}

// Satzball und Matchball
(:test)
function testSetAndMatchPoint(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    winPoints(m, ME, 4*5 + 3);                         // 5:0, 40:0
    Test.assertEqualMessage(m.pointStatus(ME), :setPoint, "Satzball");
    winPoints(m, ME, 1 + 4*5 + 3);                     // Satz 1, dann 5:0, 40:0
    Test.assertEqualMessage(m.pointStatus(ME), :matchPoint, "Matchball");
    return true;
}

// Undo stellt Satzverlauf und Punkte wieder her
(:test)
function testUndoRestoresStats(logger as Logger) as Boolean {
    var m = new MatchState(new MatchRules());
    winPoints(m, ME, 4*6);
    m.undo();
    Test.assertEqualMessage(m.setScores.size(), 0, "Satz zurückgenommen");
    Test.assertEqualMessage(m.pointsWon[ME], 23, "23 Punkte");
    Test.assertEqualMessage(m.gamesPlayed, 5, "5 Games gespielt");
    return true;
}
