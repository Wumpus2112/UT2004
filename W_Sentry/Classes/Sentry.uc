//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Sentry extends ASVehicle_Sentinel_Floor;

var float secondsToLive;
var int TeamNumber;

function int GetTeamNum(){
    return TeamNumber;
}

defaultproperties
{
     secondsToLive=120.000000
     AutoTurretControllerClass=Class'W_Sentry.SentryController'
     VehicleNameString="Sentry"
     bSimulateGravity=True
     bStationary=False
     SightRadius=5000.000000
     MaxFallSpeed=100.000000
}
