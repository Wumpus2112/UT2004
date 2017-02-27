//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SentryController extends ControllerSentryAS;

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
     AcquisitionYawRate=1000000
}
