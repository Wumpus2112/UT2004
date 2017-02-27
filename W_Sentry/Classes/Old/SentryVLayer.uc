//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SentryVLayer extends Weapon;

#exec OBJ LOAD FILE=HudContent.utx

const NUM_BARRELS = 4;
const BARREL_ROTATION_RATE = 2.0;

var()   float   ReloadDelay;
var     float   BarrelRotation;
var     float   FinalRotation;
var     bool    bRotateBarrel;
var     bool    bTimerOn;

var array<SentryV> Sentrys;
var int CurrentSentrys, MaxSentrys;
var float SentrySecsToLive, CurrentSentrySecsToLive;
var color FadedColor;

replication
{
    reliable if (bNetOwner && bNetDirty && Role == ROLE_Authority)
        CurrentSentrys;
}

simulated function DrawWeaponInfo(Canvas Canvas)
{
    NewDrawWeaponInfo(Canvas, 0.705*Canvas.ClipY);
}

simulated function NewDrawWeaponInfo(Canvas Canvas, float YPos)
{
    local int i, Half;
    local float ScaleFactor;

    ScaleFactor = 99 * Canvas.ClipX/3200;
    Half = (MaxSentrys + 1) / 2;
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor = class'HUD'.Default.WhiteColor;
    for (i = 0; i < Half; i++)
    {
        if (i >= CurrentSentrys)
            Canvas.DrawColor = FadedColor;
        Canvas.SetPos(Canvas.ClipX - (i+1) * ScaleFactor * 1.25, YPos);
        Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 391, 383, 44, 49);
    }
    for (i = Half; i < MaxSentrys; i++)
    {
        if (i >= CurrentSentrys)
            Canvas.DrawColor = FadedColor;
        Canvas.SetPos(Canvas.ClipX - (i-Half+1) * ScaleFactor * 1.25, YPos - ScaleFactor);
        Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 391, 383, 44, 49);
    }
}

simulated function bool HasAmmo()
{
    if (CurrentSentrys > 0)
        return true;

    return (FireMode[0] != None && AmmoAmount(0) >= FireMode[0].AmmoPerFire);
}

simulated function bool CanThrow()
{
    if ( AmmoAmount(0) <= 0 )
        return false;

    return Super.CanThrow();
}

simulated function CheckAliveSentrys(){
    local int newCurrentSentrys;
    local int x;

    newCurrentSentrys=0;
    for (x = 0; x < CurrentSentrys; x++){
        log("Sentry: "@x);
        if (Sentrys[x] != None){
            newCurrentSentrys++;
        }else{
            Sentrys[newCurrentSentrys] = Sentrys[x];
        }
    }
    CurrentSentrys=newCurrentSentrys;
    if(CurrentSentrys==0){
        timerOff();
    }
}


simulated function Destroyed()
{
    local int x;
    log("Destroy Sentry Start");
    if (Role == ROLE_Authority){
        log("Destroy Sentrys: "@Sentrys.Length);
        for (x = 0; x < Sentrys.Length; x++){
            log("Sentry: "@x);
            if (Sentrys[x] != None){
                Sentrys[x].Destroy();
                log("Sentry Destroyed:"@x);
            }else{
                log("Sentry NONE:"@x);
            }
        }
    }

    log("Destroy Sentry End");
    Super.Destroyed();
}

simulated function AddSentry(SentryV newTurret){
    newTurret.SetTeamNum(GetTeam());
    Sentrys[Sentrys.Length] = newTurret;
    newTurret.secondsToLive = SentrySecsToLive;
    CurrentSentrys++;
    timerOn();
}

// AI Interface
function float GetAIRating()
{
    local Bot B;
    local float EnemyDist;
    local vector EnemyDir;

    if ( AmmoAmount(0) <= 0 )
        return 0;

    B = Bot(Instigator.Controller);
    if (B == None)
        return AIRating;
    if (B.Enemy == None)
    {
        if (B.Formation() && B.Squad.SquadObjective != None && B.Squad.SquadObjective.BotNearObjective(B))
        {
            if ( DestroyableObjective(B.Squad.SquadObjective) != None && B.Squad.SquadObjective.TeamLink(B.Squad.Team.TeamIndex)
                 && DestroyableObjective(B.Squad.SquadObjective).Health < DestroyableObjective(B.Squad.SquadObjective).DamageCapacity )
                return 1.1; //hackish - don't want higher priority than anything that can heal objective

            return 1.5;
        }

        return AIRating;
    }

    // if retreating, favor this weapon
    EnemyDir = B.Enemy.Location - Instigator.Location;
    EnemyDist = VSize(EnemyDir);
    if ( EnemyDist > 1500 )
        return 0.1;
    if ( B.IsRetreating() )
        return (AIRating + 0.4);
    if ( -1 * EnemyDir.Z > EnemyDist )
        return AIRating + 0.1;
    if ( (B.Enemy.Weapon != None) && B.Enemy.Weapon.bMeleeWeapon )
        return (AIRating + 0.3);
    if ( EnemyDist > 1000 )
        return 0.35;
    return AIRating;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
    local AIController C;

    C = AIController(Instigator.Controller);
    if (C == None || C.Enemy == None)
        return 0;

    if (CurrentSentrys < 1 || VSize(C.Enemy.Location - Instigator.Location) < 2500 || FRand() < 0.5)
        return 0;

    return 1;
}

function int GetTeam(){
    local int teamIndex;
    teamIndex = xPawn(Owner).PlayerReplicationInfo.Team.TeamIndex;
    return teamIndex;
}

function float SuggestAttackStyle()
{
    local Bot B;
    local float EnemyDist;

    B = Bot(Instigator.Controller);
    if ( (B == None) || (B.Enemy == None) )
        return 0.4;

    EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
    if ( EnemyDist > 1500 )
        return 1.0;
    if ( EnemyDist > 1000 )
        return 0.4;
    return -0.4;
}

function float SuggestDefenseStyle()
{
    local Bot B;

    B = Bot(Instigator.Controller);
    if ( (B == None) || (B.Enemy == None) )
        return 0;

    if ( VSize(B.Enemy.Location - Instigator.Location) < 1600 )
        return -0.6;
    return 0;
}

function bool ShouldFireWithoutTarget()
{
    local ONSPowerCore OPC;
    if ( ShootTarget(Instigator.Controller.Target) != None )
    {
        OPC = ONSPowerCore(Instigator.Controller.Target.Owner);
        if ( (OPC != None) && !OPC.Shield.bHidden )
        {
            Instigator.Controller.Target = OPC.PathList[Rand(OPC.PathList.Length)].End;
            return ( Instigator.Controller.Target != None );
        }
    }
    if (CurrentSentrys < MaxSentrys)
        return true;

    return false;
}

// End AI Interface


simulated function PlayFiring(bool plunge)
{
    GotoState('AnimateLoad', 'Begin');
}

simulated function RotateBarrel()
{
    FinalRotation -= 65535.0 / NUM_BARRELS;
    if (FinalRotation <= 0.0)
    {
        FinalRotation += 65535.0;
        BarrelRotation += 65535.0;
    }
    bRotateBarrel = True;
}

simulated function UpdateBarrel(float dt)
{
    local Rotator R;

    BarrelRotation -= dt * 65535.0 * BARREL_ROTATION_RATE / NUM_BARRELS;
    if (BarrelRotation < FinalRotation)
    {
        BarrelRotation = FinalRotation;
        bRotateBarrel = False;
        GotoState('');
    }

    R.Roll = BarrelRotation;
    SetBoneRotation('drum', R, 0, 1);
}

simulated state AnimateLoad
{
    simulated function Tick(float dt)
    {
        if (bRotateBarrel)
            UpdateBarrel(dt);
    }

Begin:
    sleep(ReloadDelay);
    RotateBarrel();
    PlaySound(sound'PickupSounds.FlakAmmoPickup', SLOT_Misc);
    ClientPlayForceFeedback("FlakAmmoPickup");
}

// end AI Interface
simulated function float ChargeBar()
{
    return FMin(1,CurrentSentrySecsToLive/SentrySecsToLive);
}

function timerOff(){
    log("Timer off");
    bTimerOn = false;
    CurrentSentrySecsToLive=0;
}

function timerOn(){
    log("Timer on");
    if(bTimerOn) return;
    bTimerOn = true;
    CurrentSentrySecsToLive=SentrySecsToLive;
}

function Tick(float DeltaTime)
{
    local int i;

    if(!bTimerOn) return;
    if(Sentrys.Length == 0) return;
    for(i=0; i < Sentrys.Length ; i++){
        if(Sentrys[i] != none){
            Sentrys[i].secondsToLive = Sentrys[i].secondsToLive-DeltaTime;
            if(Sentrys[i].secondsToLive < 0){
                Sentrys[i].secondsToLive =0;
                Sentrys[i].Destroy();
                log("Destroyed");
                CheckAliveSentrys();
            }
        }
    }

    if(Sentrys.Length == 0 || Sentrys[0] == none){
        CurrentSentrySecsToLive = 0;
        return;
    }
    CurrentSentrySecsToLive = Sentrys[0].secondsToLive;
}

defaultproperties
{
    ItemName="Sentry V Builder"
    Description="Builds Sentrys that automatically targets enemies."
    IconMaterial=Material'HudContent.Generic.HUD'
    IconCoords=(X1=229,Y1=258,X2=296,Y2=307)

    FireModeClass(0)=SentryVThrowFire
    FireModeClass(1)=SentryVThrowFire

     InventoryGroup=0
     GroupOffset=1

    //Mesh=Mesh'ONSWeapons-A.MineLayer_1st'
    //Skins[0]=Shader'UT2004Weapons.Shaders.LinkGunShader'

//    DrawType=DT_Mesh
       Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretBase'

    bShowChargingBar=true

    BobDamping=2.2
    PickupClass=class'W_Sentry.SentryVPickup'
    EffectOffset=(X=100.0,Y=32.0,Z=-20.0)
    AttachmentClass=class'SentryLayerAttachment'
    PutDownAnim=PutDown
    ReloadDelay=0.4;
    BringUpTime=0.35
    PutDownTime=0.40
    PutDownAnimRate=4.0
    SelectAnimRate=2.0

    DisplayFOV=45
    AmbientGlow=64.0
    DrawScale=1.0
    PlayerViewOffset=(X=100,Y=35.5,Z=-32.5)
    SmallViewOffset=(X=116,Y=43.5,Z=-40.5)
    PlayerViewPivot=(Pitch=0,Roll=0,Yaw=0)
    SelectSound=Sound'WeaponSounds.FlakCannon.SwitchToFlakCannon'
    SelectForce="SwitchToFlakCannon"

    AIRating=+0.55
    CurrentRating=+0.55
    HudColor=(r=0,g=0,b=255,a=255)
     Priority=16
    CustomCrosshair=14
    CustomCrosshairTextureName="ONSInterface-TX.MineLayerReticle"
    CustomCrosshairColor=(r=255,g=255,b=255,a=255)

    bTimerOn=false;
    MaxSentrys=1
    SentrySecsToLive=10;
    FadedColor=(R=128,G=128,B=128,A=160)


}
