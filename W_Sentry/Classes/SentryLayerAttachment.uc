//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SentryLayerAttachment extends xWeaponAttachment;

var xEmitter MuzFlash3rd;

simulated function Destroyed()
{
    if (MuzFlash3rd != None)
        MuzFlash3rd.Destroy();
    Super.Destroyed();
}

defaultproperties
{
     bHeavy=True
     Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretBase'
     DrawScale=0.150000
}
