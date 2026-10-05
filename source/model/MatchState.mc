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

    function initialize(r as MatchRules) {
        rules = r;  
        points = [0, 0];
        games = [0, 0]; 
        sets = [0, 0]; 
        finished = false; 
        tiebreak = false; 
        server = rules.firstServer; 
        history = []; 
    }

    function pointWon(player as Number) as Void {
          if(finished) {
            return;
        }

        history.add(copy()); 
        var other = 1 - player; 
        points[player] += 1; 

        var needed = 4; 
        var lead = 2;
        if (tiebreak) {
            needed = 7; 
        } else if (rules.noAd == true) {
            lead = 1;
        }

        if(points[player] >= needed && (points[player] - points[other]) >= lead){
            gameWon(player); 
        }
    }

    function currentServer() as Number {
        if(!tiebreak) {
            return server; 
        }

        var played = points[ME] + points[OPPONENT]; 
        var pos = played % 4; 

        if (pos == 1 || pos == 2) {
            var otherServer = 1 - server; 
            return otherServer; 
        }

        return server; 
    }

   private function gameWon(player as Number) as Void {
        server = 1 - server; 
        games[player] += 1; 
        points = [0, 0]; 
        var other = 1 - player; 

        if (tiebreak) {
            tiebreak = false; 
            setWon(player); 
        } else if (games[player] >= 6 && (games[player] - games[other]) >= 2) {
            setWon(player);
        } else if (games[player] >= 6 && games[other] >= 6){
            tiebreak = true; 
        }

      
    }

    private function setWon(player as Number) as Void {
        sets[player] += 1; 
        games = [0, 0]; 

        if(sets[player] >= rules.setsToWin){
            finished = true;
        }
    }
    
    private function copy() as MatchState {
        var c = new MatchState(rules); 
        c.points = [points[ME], points[OPPONENT]]; 
        c.games = [games[ME], games[OPPONENT]]; 
        c.sets = [sets[ME], sets[OPPONENT]]; 
        c.finished = finished; 
        c.tiebreak = tiebreak; 
        c.server = server; 
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

   }


}