//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Apache_Weapon extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var int LoadedShotCount, MaxShotCount;  // LoadedShotCount = # of shots loaded, MaxShotCount = Max # to load

var sound ReloadSound;          // Sound to play when loading a rocket

var bool bDumpingLoad, bReload;          // Are we dumping our load of rockets?
var Controller FireControl;     // Temp. Storage of who is doing the firing.
var int reloadDelay;

var float MinAim;

event bool AttemptFire(Controller C, bool bAltFire)
{
    if(Role != ROLE_Authority || bForceCenterAim )
        return False;

    if(!bAltFire) {
        return super.AttemptFire(c,bAltFire);
    }

    if (LoadedShotCount>0 && !bDumpingLoad)
    {
        FireControl = C;
        bDumpingLoad=true;
        bReload=false;
        FireSingle(FireControl,bAltFire);
        Enable('timer');
        SetTimer(0.5,true);
    }else{
        if(bReload==false){
            bDumpingLoad=false;
            bReload=true;
            Enable('timer');
            SetTimer(0.5,true);
        }
    }
    return False;
}

function FireSingle(Controller C, bool bAltFire, optional bool bDontSkip)
{

        CalcWeaponFire();
        if (bCorrectAim)
            WeaponFireRotation = AdjustAim(false);

        DualFireOffset *= -1;

        Instigator.MakeNoise(1.0);
        FireCountdown = FireInterval;
        AltFire(C);
        bDontSkip = !bDontSkip;
        FireCountdown = FireInterval;

}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local vector StartLocation;

    if(!bAltFire){
        Apache(Instigator).GetBestTarget();
        return super.SpawnProjectile(ProjClass,bAltFire);
    }

    LoadedShotCount--;
    if(!bDumpingLoad || LoadedShotCount<=-1){
        LoadedShotCount++;
        return none;
    }

    if ( Bot(Instigator.Controller) != None )
        Vehicle(Instigator).Rise = 0;

    StartLocation = WeaponFireLocation;

    P = spawn(ProjClass, self, , StartLocation, Instigator.Rotation);

    ProjectileHydraRocket(P).HomingTarget = GetTarget();

    return P;
}

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
    if (Level.NetMode != NM_Client)
        return;

    super.ClientStopFire(C,bWasAltFire);
}

function Timer()
{

   if (LoadedShotCount>0 && bDumpingLoad)
    {
        FireSingle(FireControl,true);
        bReload = false;
    }else{
        bReload = true;
        bDumpingLoad = false;
        reloadDelay--;
        if(reloadDelay == 0){
            reloadDelay = 3;
            if (LoadedShotCount<MaxShotCount)
            {
                bReload = true;
                LoadedShotCount++;
                PlaySound(sound'CicadaSnds.Missile.MissileLoad');
                Instigator.MakeNoise(1.0);
            }else{
                bReload = false;
                Disable('Timer');
                SetTimer(0,false);
            }
        }
    }

}

function WeaponCeaseFire(Controller C, bool bWasAltFire)
{
    bReload =true;
    bDumpingLoad=false;

}

simulated event OwnerEffects()
{
    if (Level.NetMode == NM_Client && bIsAltFire)
        LoadedShotCount++;

    if (LoadedShotCount<MaxShotCount)
        super.OwnerEffects();

}

function Vehicle GetTarget()
{
    return Apache(Instigator).CurrentTarget;
}

defaultproperties
{
     LoadedShotCount=8
     MaxShotCount=8
     ReloadDelay=6
     YawBone="Bone01"
     PitchBone="Bone01"
     PitchUpLimit=7500
     PitchDownLimit=45500
     WeaponFireAttachmentBone="Bone01"
     WeaponFireOffset=85.000000
     DualFireOffset=5.000000
     RotationsPerSecond=1.000000
     bInstantRotation=True
     bDoOffsetTrace=True
     FireInterval=0.100000
     AltFireInterval=1.500000
     AmbientEffectEmitterClass=Class'Onslaught.ONSRVChainGunFireEffect'
     FireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     AltFireSoundClass=Sound'CicadaSnds.Missile.MissileEject'
     AltFireSoundVolume=70.000000
     AmbientSoundScaling=1.300000
     ProjectileClass=Class'W_Apache.Projectile_30mm'
     AltFireProjectileClass=Class'W_Apache.ProjectileHydraRocket'
     Mesh=SkeletalMesh'DN_AtakapaAnim.Atakapa50Cal'
}
