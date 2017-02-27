//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Weapon_PhantomX extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var float MinAim;

function byte BestMode()
{
    local bot B;

    B = Bot(Instigator.Controller);
    if ( B == None )
        return 0;

    if ( (Vehicle(B.Enemy) != None)
         && (B.Enemy.bCanFly || B.Enemy.IsA('ONSHoverCraft')) && (FRand() < 0.3 + 0.1 * B.Skill) )
        return 1;
    else
        return 0;
}

state ProjectileFireMode
{

    function AltFire(Controller C)
    {
        local ONSAttackCraftMissle M;
        local Vehicle V, Best;
        local float CurAim, BestAim;

        M = ONSAttackCraftMissle(SpawnProjectile(AltFireProjectileClass, True));
        if (M != None)
        {
            if (AIController(Instigator.Controller) != None)
            {
                V = Vehicle(Instigator.Controller.Enemy);
                if (V != None && (V.bCanFly || V.IsA('ONSHoverCraft')) && Instigator.FastTrace(V.Location, Instigator.Location))
                    M.SetHomingTarget(V);
            }
            else
            {
                BestAim = MinAim;
                for (V = Level.Game.VehicleList; V != None; V = V.NextVehicle)
                    if ((V.bCanFly || V.IsA('ONSHoverCraft')) && V != Instigator && Instigator.GetTeamNum() != V.GetTeamNum())
                    {
                        CurAim = Normal(V.Location - WeaponFireLocation) dot vector(WeaponFireRotation);
                        if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location))
                        {
                            Best = V;
                            BestAim = CurAim;
                        }
                    }
                if (Best != None)
                    M.SetHomingTarget(Best);
            }
        }
    }
}


DefaultProperties
{
    MinAim=0.90

    YawBone=FGearBone

    PitchBone=FGearBone

    PitchUpLimit=18000

    PitchDownLimit=49153

    WeaponFireAttachmentBone=FGearBone

    DualFireOffset=50.00

    RotationsPerSecond=1.20

    FireInterval=0.10

    AltFireInterval=1.00

    FireSoundClass=Sound'ONSVehicleSounds-S.LaserSounds.Laser01'

    AltFireSoundClass=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'

    FireForce="Laser01"

    AltFireForce="Laser01"

    ProjectileClass=Class'APVerIV.Weapon_VulcanCannon'

    AltFireProjectileClass=Class'APVerIV.Weapon_PhoenixMissile"'

//    AIInfo(0)=
//    AIInfo(1)=

}
