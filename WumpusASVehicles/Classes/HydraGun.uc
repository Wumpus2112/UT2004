//-----------------------------------------------------------
// ONSDaulACSideGun - (C) 2004, Epic Games
// Joe Wilcox
//
// This is the primary weapon the Cicada.
//-----------------------------------------------------------
class HydraGun extends ONSWeapon;

var int LoadedShotCount, MaxShotCount;  // LoadedShotCount = # of shots loaded, MaxShotCount = Max # to load

var sound ReloadSound;          // Sound to play when loading a rocket

var bool bDumpingLoad, bReload;          // Are we dumping our load of rockets?
var Controller FireControl;     // Temp. Storage of who is doing the firing.
var int reloadDelay;


event bool AttemptFire(Controller C, bool bAltFire)
{
    if(Role != ROLE_Authority || bForceCenterAim )
        return False;

//    log("AttemptFire");

    if (LoadedShotCount>0 && !bDumpingLoad)
    {
        FireControl = C;
        bDumpingLoad=true;
        bReload=false;
        FireSingle(FireControl,true);
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
        Fire(C);
        bDontSkip = !bDontSkip;
        FireCountdown = FireInterval;

}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local vector StartLocation;

    LoadedShotCount--;
    if(!bDumpingLoad || LoadedShotCount<=-1){
        LoadedShotCount++;
        return none;
    }

    if ( Bot(Instigator.Controller) != None )
        Vehicle(Instigator).Rise = 0;

    StartLocation = WeaponFireLocation;
//    Rand = (400 * frand()) + 200;   // This is our range for the ejection.

//    StartVelocity = Instigator.Velocity;

    P = spawn(ProjClass, self, , StartLocation, Instigator.Rotation);

    //P.Velocity = 200; // Apply the velocity

    ProjectileHydraRocket(P).HomingTarget = GetTarget();

    return P;
}

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
//    log("ClientStopFire");

    if (Level.NetMode != NM_Client)
        return;

    super.ClientStopFire(C,bWasAltFire);
}

function Timer()
{
//   log("Timer");
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
//   log("WeaponCeaseFire");

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
    log("CurrentTarget:"$Apache(Instigator).CurrentTarget.VehicleNameString);

    return Apache(Instigator).CurrentTarget;
}

defaultproperties
{
    Mesh=Mesh'ONSFullAnimations.MASRocketPack'
    FireInterval=2.0
    DrawScale = 0.25
    PrePivot = (X=0,Y=0,Z=8)
    DualFireOffset=10.0

    YawBone=RL_Right
    PitchBone=RL_Right
    WeaponFireAttachmentBone=FirePoint
    ProjectileClass=class'ProjectileHydraRocket'
    AltFireProjectileClass=class'ProjectileHydraRocket'
    AltFireInterval=0.33
    YawStartConstraint=-5000
    YawEndConstraint=5000
    PitchUpLimit=18000
    PitchDownLimit=50000
    AltFireSoundClass=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
    bAimable=True
    RotationsPerSecond=0.09
    MaxShotCount=8
    LoadedShotCount=12
    reloadDelay=3;
    FireSoundVolume=70.0
    AltFireSoundVolume=70.0
    bInstantRotation=true
    AIInfo(0)=(bLeadTarget=true,bTrySplash=true,WarnTargetPct=0.5,RefireRate=0.99)
    AIInfo(1)=(bLeadTarget=false,bTrySplash=true,WarnTargetPct=0.2,RefireRate=0.99)
    CullDistance=+7000.0

}
