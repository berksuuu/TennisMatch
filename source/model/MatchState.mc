import Toybox.Lang; 

const ME = 0; 
const OPPONENT = 1; 
const SETS_TO_WIN = 2; 

class MatchState {

    var points as Array<Number>; 
    var games as Array<Number>;
    var sets as Array<Number>; 
    var finished as Boolean;  

    function initialize() {
        points = [0, 0];
        games = [0, 0]; 
        sets = [0, 0]; 
        finished = false; 
    }

    function pointWon(player as Number) as Void {
          if(finished) {
            return;
        }

        var other = 1 - player; 
        points[player] += 1; 

        if(points[player] >= 4 && (points[player] - points[other]) >= 2){
            gameWon(player); 
        }
    }

   private function gameWon(player as Number) as Void {
        games[player] += 1; 
        points = [0, 0]; 
        var other = 1 - player; 

        if(games[player] >= 6 && (games[player] - games[other]) >= 2) {
            setWon(player); 
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