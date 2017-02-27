//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSNeutralVehicleRotatorFactory extends ONSVehicleRotatorFactory;

// Ignores team number, and always uses team 255
function Activate(byte T)
{
    if (!bNeverActivate && !bActive)
    {
        TeamNum = default.TeamNum;
        bActive = True;
        bPreSpawn = True;
        Timer();
    }
}

function SpawnVehicle()
{
	Super.SpawnVehicle();

	if (LastSpawned != None)
		LastSpawned.bTeamLocked = False;
}

DefaultProperties
{
    RedBuildEffectClass=class'W_VehicleRotator.ONSBuildEffectGreen'
    BlueBuildEffectClass=class'W_VehicleRotator.ONSBuildEffectGreen'
}
