//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SentryXThrowFire extends BioFire;

var class<Projectile> RedMineClass;
var class<Projectile> BlueMineClass;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local class<actor> NewClass;
    local vector SpawnLoc;
    local actor newTurret;
    local string ClassName;

    if (SentryXLayer(Weapon) != None)
    {
        SentryXLayer(Weapon).CheckAliveSentrys();
        if (SentryXLayer(Weapon).CurrentSentrys < SentryXLayer(Weapon).MaxSentrys){

        /*
        for (x = 0; x < SentryLayer(Weapon).Sentrys.length; x++)
        {
            if (SentryLayer(Weapon).Sentrys[x] == None)
            {
                SentryLayer(Weapon).Sentrys.Remove(x, 1);
                x--;
            }
            else
            {
                SentryLayer(Weapon).Sentrys[x].Destroy();
                SentryLayer(Weapon).Sentrys.Remove(x, 1);
                break;
            }
        }
        */


            ClassName = "W_Sentry.SentryX";

            NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
            if( NewClass!=None )
            {
                log("Sentry created:"$ClassName);

                SpawnLoc = Start;
                newTurret = Spawn( NewClass,,,SpawnLoc + 72 * vector(Dir) + vect(0,0,1) * 15 );
                SentryXLayer(Weapon).AddSentry(SentryX(newTurret));
            }else{
                log("error Sentry not create");
            }

        }else{
            log("Sentrys Maxed out - Current:"@SentryXLayer(Weapon).CurrentSentrys@" Max:"@SentryXLayer(Weapon).MaxSentrys);
        }
    }else{
        log("Sentry class not found:"@Weapon);
    }

    return none;
}

function PlayFiring()
{
    Super.PlayFiring();
    SentryXLayer(Weapon).PlayFiring(true);
}

defaultproperties
{
    AmmoClass=class'W_Sentry.SentryAmmo'
    ProjectileClass=class'Onslaught.ONSMineProjectile'
    RedMineClass=class'Onslaught.ONSMineProjectileRED'
    BlueMineClass=class'Onslaught.ONSMineProjectileBLUE'
    FireSound=Sound'ONSVehicleSounds-S.SpiderMines.SpiderMineFire01'
    FireRate=1.1
}
