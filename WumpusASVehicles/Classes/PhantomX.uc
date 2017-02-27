//=============================================================================
// Phantom
// Stealth Fighter/Bomber
// Pilot Controls Guns,Air to Air Missiles and Invisability Cloak.
//  Bombs And Redeemer Bomb.
//=============================================================================

class PhantomX extends WumpusASVehicleAir config(PhantomX) placeable;

var Material RealSkins[4];

function Fire (optional float F)
{
  if ( bReadyForTakeOff == False )
  {
    DesiredVelocity = EngineMinVelocity + 260;
    Velocity = EngineMinVelocity * Vector(Rotation);
    Acceleration = Velocity;
    bLanded = False;
    bReadyForTakeOff = True;
    bGearUp = True;
    PlayAnim('GearsUp');
    if ( LaunchSound != None )
    {
        PlaySound(LaunchSound, SLOT_None, 2.0);
    }
  }
}

simulated function SetTrailFX ()
{
  if ( (Thruster == None) && (Health > 0) && (Team != 255) )
  {
    Thruster = Spawn(Class'FX_PhantomXThrusters',self);
    Thruster.SetBase(self);
    AttachToBone(Thruster,'MidEngine');
  }
  if ( (Thruster != None) && ((Team == 0) || (Controller != None) && (Controller.PlayerReplicationInfo.Team.TeamIndex == 0)) )
  {
    Thruster.SetRedColor();
  }
  if ( (Thruster != None) && ((Team == 1) || (Controller != None) && (Controller.PlayerReplicationInfo.Team.TeamIndex == 1)) )
  {
    Thruster.SetBlueColor();
  }
}

simulated function SetRunningLightsFX ()
{
  if ( (LeftWingLight == None) && (Health > 0) && (Team != 255) )
  {
    LeftWingLight = Spawn(Class'FX_RunningLight',self,,Location);
    AttachToBone(LeftWingLight,'LWLight');
    RightWingLight = Spawn(Class'FX_RunningLight',self,,Location);
    AttachToBone(RightWingLight,'RWLight');
    BottomLight = Spawn(Class'FX_RunningLight',self,,Location);
    AttachToBone(BottomLight,'BLight');
  }
  if ( LeftWingLight != None )
  {
    if ( (Team == 1) || (Controller != None) && (Controller.PlayerReplicationInfo.Team.TeamIndex == 1) )
    {
      LeftWingLight.SetBlueColor();
      RightWingLight.SetBlueColor();
      BottomLight.SetBlueColor();
    } else {
      if ( (Team == 0) || (Controller != None) && (Controller.PlayerReplicationInfo.Team.TeamIndex == 0) )
      {
        LeftWingLight.SetRedColor();
        RightWingLight.SetRedColor();
        BottomLight.SetRedColor();
      }
    }
  }
}

simulated function AdjustEngineFX ()
{
  local Vector FXAmount;
  local float CurrThrust;

  CurrThrust = FClamp( (Velocity dot Vector(Rotation)) * 1000.f / AirSpeed, 0.f, 1000.f);
//  FXAmount.Z = 0.03 * CurrThrust;
  FXAmount.Z = 0.001 * CurrThrust;

//  FXAmount.Y = 0.02 * CurrThrust;
  FXAmount.X = 1.12;
  FXAmount.Y = 1.0;

  /*  **
  FXAmount.X = 0.005 * CurrThrust;
  FXAmount.Z = 1.12;
  FXAmount.Y = 1.0;
    */

  if ( Thruster != None )
  {
    Thruster.SetDrawScale3D(FXAmount);

  }
}

simulated function PlayTakeOff ()
{
}

function PossessedBy (Controller C)
{
  Super.PossessedBy(C);
  if ( Controller.IsA('Bot') )
  {
    AirSpeed = 2800.0;
    AccelRate = 1200.0;
    bLanded = False;
    bReadyForTakeOff = True;
    bGearUp = True;
    PlayAnim(LandingGearsUp);
  } else {
    AirSpeed = 3000.0;
    AccelRate = 2000.0;
  }
}

simulated function bool SpecialCalcView (out Actor ViewActor, out Vector CameraLocation, out Rotator CameraRotation)
{
  local Vector CamLookAt;
  local Vector HitLocation;
  local Vector HitNormal;
  local PlayerController PC;
  local float CamDistFactor;
  local Vector CamDistance;
  local Rotator CamRotationRate;
  local Rotator TargetRotation;

  PC = PlayerController(Controller);
  if ( (PC == None) || (PC.ViewTarget == None) )
  {
    return False;
  }
  ViewActor = self;
  if (  !PC.bBehindView )
  {
    SpecialCalcFirstPersonView(PC,ViewActor,CameraLocation,CameraRotation);
    return True;
  }
  myDeltaTime = Level.TimeSeconds - LastTimeSeconds;
  LastTimeSeconds = Level.TimeSeconds;
  CamLookAt = ViewActor.Location + (vect(60.00,0.00,0.00) >> ViewActor.Rotation);
  if ( ViewActor == self )
  {
    TargetRotation = GetViewRotation();
  } else {
    TargetRotation = ViewActor.Rotation;
  }
  if ( IsInState('ShotDown') )
  {
    TargetRotation.Yaw += 56768;
    Normalize(TargetRotation);
    CamRotationInertia = Default.CamRotationInertia * 10.0;
    CamDistFactor = 1024.0;
  } else {
    if ( IsInState('Dying') )
    {
      CamRotationInertia = Default.CamRotationInertia * 50.0;
      CamDistFactor = 3.0;
    } else {
      CamDistFactor = 1.0 - DesiredVelocity / AirSpeed;
    }
  }
  CamRotationRate = Normalize(TargetRotation - LastCamRot);
  CameraRotation.Yaw = int(CalcInertia(myDeltaTime,CamRotationInertia,CamRotationRate.Yaw,LastCamRot.Yaw));
  CameraRotation.Pitch = int(CalcInertia(myDeltaTime,CamRotationInertia,CamRotationRate.Pitch,LastCamRot.Pitch));
  CameraRotation.Roll = int(CalcInertia(myDeltaTime,CamRotationInertia,CamRotationRate.Roll,LastCamRot.Roll));
  LastCamRot = CameraRotation;
  CamDistance = vect(-686.00,0.00,128.00);
  CamDistance.X -= CamDistFactor * 200.0;
  CameraLocation = CamLookAt + (CamDistance >> CameraRotation);
  if ( Trace(HitLocation,HitNormal,CameraLocation,ViewActor.Location,False,vect(10.00,10.00,10.00)) != None )
  {
    CameraLocation = HitLocation + HitNormal * 10;
  }



  return True;
}


simulated function DrawHUD(Canvas C){

    local PlayerController PC;

    super.DrawHUD(C);

    DrawTargetting( C );

    PC = PlayerController(Controller);
    if ( (PC == None) || (PC.ViewTarget == None) ){
        return;
    }

    // All of the special view stuff!!!!
    DrawSpeedMeter( C, PC.myHUD, PC );
    DrawVehicleHUD( C, PC );

}


defaultproperties
{
    FlyingAnim=Flying
    ShotDownFXClass=Class'UT2k4AssaultFull.FX_SpaceFighter_ShotDownEmitter'
    SpeedInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid'
    LandingGearsUp=GearsUp
    LandingGearsDown=GearsDown
    NumChaff=4
    LaunchSpeed=2600.00
    FlybySound=Sound'APVerIV_Snd.PhantomFlyby'
    FlybyInterval=6.50

//    DriverWeapons(0)=(WeaponClass=Class'Onslaught.ONSAttackCraftGun',WeaponBone="FGearBone")
//    DefaultWeaponClassName="Battlestar.Weapon_WeaponZeroG"

    DefaultWeaponClassName="WumpusASVehicles.Weapon_WeaponPhantomX";

//    RequiredFighterEquipment(0)="APVerIV.Weapon_PhantomGuns"
//    RequiredFighterEquipment(1)="APVerIV.Weapon_StealthActivator"

    VehicleProjSpawnOffsetLeft=(X=-86.00,Y=-132.00,Z=18.00),
    VehicleProjSpawnOffsetRight=(X=-86.00,Y=132.00,Z=18.00),
    RocketOffsetA=(X=-20.00,Y=-86.00,Z=-25.00),
    RocketOffsetB=(X=-20.00,Y=86.00,Z=-25.00),
    GunOffsetA=(X=20.00,Y=45.00,Z=-5.00),
    GunOffsetB=(X=20.00,Y=-45.00,Z=-5.00),
    //PassengerWeapons=[0]=(WeaponPawnClass (Object) = Class'WeaponPawn_PhantomBomber',WeaponBone (Name) = PassAttach,)
    ExplosionEffectClass=Class'FX_VehDeathPhantom'
    IdleSound=Sound'APVerIV_Snd.enginesB'
    StartUpSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftStartUp'
    ShutDownSound=Sound'APVerIV_Snd.LandingD'
    LaunchSound=Sound'APVerIV_Snd.EnginesLightupA'
    bCustomHealthDisplay=True
    ExitPositions(0)=(X=-1024.000000,Z=256.000000)
    ExitPositions(1)=(X=-1024.000000,Z=256.000000)
    ExitPositions(2)=(X=-1024.000000,Z=256.000000)
    ExitPositions(3)=(X=-1024.000000,Z=256.000000)
    FPCamPos=(X=15.00,Y=0.00,Z=20.00),
    VehiclePositionString="in a Phantom Stealth Fighter"
    VehicleNameString="Phantom Stealth Fighter"
    FlagBone=PassAttach
    FlagOffset=(X=0.00,Y=0.00,Z=80.00),
//    AirSpeed=2600.00
    AirSpeed=5000.00
    AmbientSound=Sound'AssaultSounds.HumanShip.HnSpaceShipEng01'
    Mesh=SkeletalMesh'WumpusASVehiclesAni.PhantomMesh'
    DrawScale=1.30
    Skins(0)=Shader'APVerIV_Tex.ExcaliburSkins.GlassShader'
    Skins(1)=Texture'APVerIV_Tex.PhantomSkins.PhantomSkinA'
    Skins(2)=Texture'APVerIV_Tex.PhantomSkins.PhantomSkinB'
    AmbientGlow=86
    SoundRadius=100.00
    TransientSoundVolume=1.00
    TransientSoundRadius=784.00

    EntryPosition=(X=0,Y=0,Z=-20)
    EntryRadius=300

    CollisionHeight=68.00
    CollisionRadius=120.00
}

