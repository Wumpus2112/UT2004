//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SentryPBController extends SentryBaseController;

    var int TeamNumber;

simulated function int GetTeamNum()
{
	log("Team Number:"@TeamNumber);
    return TeamNumber;
}

function bool IsSpawnCampProtecting()
{
	return true;
}

defaultproperties
{
     Skill=10.000000
}
