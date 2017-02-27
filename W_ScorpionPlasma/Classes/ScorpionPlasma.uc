//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ScorpionPlasma extends ONSRV;
var float gravity;

function VehicleFire(bool bWasAltFire)
{
    if (bWasAltFire)
    {
        gravity = KarmaParams(KParams).KActorGravScale;

        if (!bLeftArmBroke && !bRightArmBroke)
        {
            if(KarmaParams(KParams).KActorGravScale < gravity){
                KarmaParams(KParams).KActorGravScale = KarmaParams(KParams).KActorGravScale*4;
            }
            KarmaParams(KParams).KActorGravScale = gravity/4;
        }
    }
    Super.VehicleFire(bWasAltFire);
}

function VehicleCeaseFire(bool bWasAltFire)
{
    if (bWasAltFire)
    {
        KarmaParams(KParams).KActorGravScale = gravity;
    }

    super.VehicleCeaseFire(bWasAltFire);
}

defaultproperties
{
     DriverWeapons(0)=(WeaponClass=Class'W_ScorpionPlasma.PlasmaWeapon')
     VehiclePositionString="in a Plasma Scorpion"
     VehicleNameString="Plasma Scorpion"
}
