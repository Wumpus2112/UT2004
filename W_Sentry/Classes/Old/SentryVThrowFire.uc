//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SentryVThrowFire extends BioFire;

var class<Projectile> RedMineClass;
var class<Projectile> BlueMineClass;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local class<actor> NewClass;
    local vector SpawnLoc;
    local SentryV newTurret;
    local string ClassName;

    if (SentryVLayer(Weapon) != None)
    {
        SentryVLayer(Weapon).CheckAliveSentrys();
        if (SentryVLayer(Weapon).CurrentSentrys < SentryVLayer(Weapon).MaxSentrys){

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

         //            NewChunk = Spawn( class 'FlackTurretSubProjectile',, '', Start, rot);

                log("Sentry created:"$ClassName);
                SpawnLoc = Start;
                newTurret = Spawn( class 'SentryV',,,SpawnLoc + 72 * vector(Dir) + vect(0,0,1) * 15 );
                newTurret.Controller.Pawn = newTurret;
                log("Sentry created:"$newTurret);
                SentryVLayer(Weapon).AddSentry(newTurret);

        }else{
            log("Sentrys Maxed out - Current:"@SentryVLayer(Weapon).CurrentSentrys@" Max:"@SentryVLayer(Weapon).MaxSentrys);
        }
    }else{
        log("Sentry class not found:"@Weapon);
    }

    return none;
}

function PlayFiring()
{
    Super.PlayFiring();
    SentryVLayer(Weapon).PlayFiring(true);
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
