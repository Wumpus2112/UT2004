//-----------------------------------------------------------
//
//-----------------------------------------------------------
class xWumpusPlayer extends xPlayer;

var             int         spawnWait;
var             bool        bWaiting;

function ServerShowPathToBase(int TeamNum){
    super.ServerShowPathToBase(TeamNum);
}

defaultproperties
{
}
