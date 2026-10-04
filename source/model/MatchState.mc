import Toybox.Lang; 

const ME = 0; 
const OPPONENT = 1; 
const SETS_TO_WIN = 2; 

class MatchState {

    var points as Array<Number>; 
    var games as Array<Number>;
    var sets as Array<Number>; 
    var finished as Boolean;  
    var tiebreak as Boolean; 
    var server as Number; 

    function initialize() {
        points = [0, 0];
        games = [0, 0]; 
        sets = [0, 0]; 
        finished = false; 
        tiebreak = false; 
        server = ME; 
    }

    function pointWon(player as Number) as Void {
          if(finished) {
            return;
        }

        var other = 1 - player; 
        points[player] += 1; 

        var needed = 4; 
        if (tiebreak) {
            needed = 7; 
        }

        if(points[player] >= needed && (points[player] - points[other]) >= 2){
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

        if(sets[player] >= SETS_TO_WIN){
            finished = true;
        }
    }
    

}