import Toybox.Lang; 

const ME = 0; 
const OPPONENT = 1; 

class MatchState {

    var points as Array<Number>; 
    var games as Array<Number>; 

    function initialize() {
        points = [0, 0];
        games = [0, 0]; 
    }

    function pointWon(player as Number) as Void {
        var other = 1 - player; 
        points[player] += 1; 

        if(points[player] >= 4 && (points[player] - points[other]) >= 2){
            gameWon(player); 
        }
    }

   private function gameWon(player as Number) as Void {
        games[player] += 1; 
        points = [0, 0]; 
    }

}