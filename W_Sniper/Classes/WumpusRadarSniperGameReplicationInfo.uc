class WumpusRadarSniperGameReplicationInfo extends GameReplicationInfo;

var vector PlayerLocation[16];
var string PlayerName[16];
var int    PlayerTeam[16];

replication
{
    reliable if(Role == ROLE_Authority)
         PlayerLocation,PlayerTeam,PlayerName;
}

// every so often - update replication position of Mutant.
function PostBeginPlay()
{
	if(Role == ROLE_Authority)
		SetTimer(0.2, true);
}

/*
function Timer()
{
	local Controller playerController;
    local int i;

    for(){

    }

	pred = xMutantGame(Level.Game).CurrentMutant;

	if(pred != None)
	{
		MutantLocation = pred.Pawn.Location;
	}

	super.timer();
}
*/
defaultproperties
{
}
