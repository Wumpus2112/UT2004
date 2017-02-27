//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Hoverboard extends ONSHoverCraft
  Placeable
  Config(User);

var() float MaxPitchSpeed;
var() float JumpDuration;
var() float JumpForceMag;
var float JumpCountdown;
var float JumpDelay;
var float LastJumpTime;
var() float DuckDuration;
var() float DuckForceMag;
var float DuckCountdown;
var() array<Vector> BikeDustOffset;
var() float BikeDustTraceDistance;
var() Sound JumpSound;
var() sound DuckSound;
var() string JumpForce;
var array<HoverboardDust> BikeDust;
var array<Vector> BikeDustLastNormal;
var bool DoBikeJump;
var bool OldDoBikeJump;
var bool DoBikeDuck;
var bool OldDoBikeDuck;
var bool bHoldingDuck;
var bool bOverWater;
var() array<Vector> TrailEffectPositions;
var Class<HoverboardTrail> TrailEffectClass;
var array<HoverboardTrail> TrailEffects;
var() array<Vector> StreamerEffectOffset;
var Class<ONSAttackCraftStreamer> StreamerEffectClass;
var array<ONSAttackCraftStreamer> StreamerEffect;
var() Range StreamerOpacityRamp;
var() float StreamerOpacityChangeRate;
var() float StreamerOpacityMax;
var float StreamerCurrentOpacity;
var bool StreamerActive;

replication
{
  unreliable if ( bNetDirty && (Role == 4) )
    DoBikeJump;
}

function Died (Controller Killer, Class<DamageType> DamageType, Vector HitLocation)
{
  local int i;

  if ( Level.NetMode != 1 )
  {
    for(i=0;i < TrailEffects.Length;i++)
    {
      TrailEffects[i].Destroy();
    }
    TrailEffects.Length = 0;

    for(i=0;i < StreamerEffect.Length;i++)
    {
      StreamerEffect[i].Destroy();
    }
    StreamerEffect.Length = 0;
  }
  Super.Died(Killer,DamageType,HitLocation);
}

function KDriverEnter (Pawn P)
{
  bHeadingInitialized = False;
  Super.KDriverEnter(P);
}

simulated function ClientKDriverEnter (PlayerController PC)
{
  bHeadingInitialized = False;
  Super.ClientKDriverEnter(PC);
}

function bool FastVehicle ()
{
  return false;
}

function ShouldTargetMissile (Projectile P)
{
  if ( (Bot(Controller) != None) && (Level.Game.GameDifficulty > 4 + 4 * FRand()) && (VSize(P.Location - Location) < VSize(P.Velocity)) )
  {
    KDriverLeave(False);
    TeamUseTime = Level.TimeSeconds + 4;
    return;
  }
  Super.ShouldTargetMissile(P);
}

function bool TooCloseToAttack (Actor Other)
{
  if ( xPawn(Other) != None )
  {
    return False;
  }
  return Super.TooCloseToAttack(Other);
}

function Pawn CheckForHeadShot (Vector loc, Vector ray, float AdditionalScale)
{
  local Vector X;
  local Vector Y;
  local Vector Z;
  local Vector newray;

  GetAxes(Rotation,X,Y,Z);
  if ( Driver != None )
  {
    newray = ray;
    newray.Z = 0.0;
    if ( (Abs(newray Dot X) < 0.69999999) && Driver.IsHeadShot(loc,ray,AdditionalScale) )
    {
      return Driver;
    }
  }
  return None;
}

simulated function Destroyed ()
{
  local int i;

  if ( Level.NetMode != 1 )
  {
    for(i=0;i < BikeDust.Length;i++)
    {
      BikeDust[i].Destroy();
    }
    BikeDust.Length = 0;
  }
  if ( Level.NetMode != 1 )
  {
    for(i=0;i < TrailEffects.Length;i++)
    {
      TrailEffects[i].Destroy();
    }
    TrailEffects.Length = 0;

    for(i=0;i < StreamerEffect.Length;i++)
    {
      StreamerEffect[i].Destroy();
    }
    StreamerEffect.Length = 0;

  }
  Super.Destroyed();
}

simulated function DestroyAppearance ()
{
  local int i;

  if ( Level.NetMode != 1 )
  {
    for(i=0;i < BikeDust.Length;i++)
    {
      BikeDust[i].Destroy();
    }
    BikeDust.Length = 0;
  }
  Super.DestroyAppearance();
}

function bool Dodge (EDoubleClickDir DoubleClickMove)
{
  Rise = 1.0;
  return True;
}

function ChooseFireAt (Actor A)
{
  if ( (Pawn(A) != None) && (Vehicle(A) == None) && (VSize(A.Location - Location) < 1500) && Controller.LineOfSightTo(A) )
  {
    if (  !bWeaponisAltFiring )
    {
      AltFire(0.0);
    }
  } else {
    if ( bWeaponisAltFiring )
    {
      VehicleCeaseFire(True);
    }
  }
  Fire(0.0);
}

simulated event DrivingStatusChanged ()
{
  local Vector RotX;
  local Vector RotY;
  local Vector RotZ;
  local int i;

  Super.DrivingStatusChanged();
  if ( Driver == None )
  {
    Health = 0;
  }
  if ( bDriving && (Level.NetMode != 1) && (BikeDust.Length == 0) &&  !bDropDetail )
  {
    BikeDust.Length = BikeDustOffset.Length;
    BikeDustLastNormal.Length = BikeDustOffset.Length;
    for(i=0;i < BikeDust.Length;i++)
    {
      if ( BikeDust[i] == None )
      {
        BikeDust[i] = Spawn(class'HoverboardDust',self,,Location + (BikeDustOffset[i] >> Rotation));
        BikeDust[i].SetDustColor(Level.DustColor);
        BikeDustLastNormal[i] = vect(0.00,0.00,1.00);
      }
    }
  } else {
    if ( Level.NetMode != 1 )
    {
      for(i=0;i < BikeDust.Length;i++)
      {
        BikeDust[i].Destroy();
      }
      BikeDust.Length = 0;
    }
    JumpCountdown = 0.0;
  }
  if ( bDriving && (Level.NetMode != 1) &&  !bDropDetail )
  {
    GetAxes(Rotation,RotX,RotY,RotZ);
    if ( TrailEffects.Length == 0 )
    {
      TrailEffects.Length = TrailEffectPositions.Length;
      for(i=0;i < TrailEffects.Length;i++)
      {
        if ( TrailEffects[i] == None )
        {
          TrailEffects[i] = Spawn(TrailEffectClass,self,,Location + (TrailEffectPositions[i] >> Rotation));
          TrailEffects[i].SetBase(self);
          TrailEffects[i].SetRelativeRotation(rot(-16384,32768,0));
        }
      }
    }
    if ( StreamerEffect.Length == 0 )
    {
      StreamerEffect.Length = StreamerEffectOffset.Length;

      for(i=0;i < StreamerEffect.Length;i++)
      {
        if ( StreamerEffect[i] == None )
        {
          StreamerEffect[i] = Spawn(StreamerEffectClass,self,,Location + (StreamerEffectOffset[i] >> Rotation));
          StreamerEffect[i].SetBase(self);
        }
      }
    }
  } else {
    if ( Level.NetMode != 1 )
    {
 for(i=0;i < TrailEffects.Length;i++)
      {
        TrailEffects[i].Destroy();

      }
      TrailEffects.Length = 0;

       for(i=0;i < StreamerEffect.Length;i++)
      {
        StreamerEffect[i].Destroy();
      }
      StreamerEffect.Length = 0;
    }
  }
}

simulated function Tick (float DeltaTime)
{
  local float EnginePitch;
  local float hitDist;
  local int i;
  local Vector TraceStart;
  local Vector TraceEnd;
  local Vector HitLocation;
  local Vector HitNormal;
  local Actor HitActor;
  local Emitter JumpEffect;
  local KarmaParams KP;
  local float DesiredOpacity;
  local float DeltaOpacity;
  local float MaxOpacityChange;
  local float ThrustAmount;
  local TrailEmitter t;
  local Vector RelVel;
  local bool NewStreamerActive;
  local bool bIsBehindView;
  local PlayerController PC;

  if ( Level.NetMode != 1 )
  {
    EnginePitch = 64.0 + VSize(Velocity) / MaxPitchSpeed * 32.0;
    SoundPitch = byte(FClamp(EnginePitch,64.0,96.0));
    RelVel = Velocity << Rotation;
    PC = Level.GetLocalPlayerController();
    if ( (PC != None) && (PC.ViewTarget == self) )
    {
      bIsBehindView = PC.bBehindView;
    } else {
      bIsBehindView = True;
    }
    if (  !bIsBehindView )
    {
       for(i=0;i < TrailEffects.Length;i++)
      {
        TrailEffects[i].SetThrustEnabled(False);
      }
    } else {
      ThrustAmount = FClamp(OutputThrust,0.0,1.0);

       for(i=0;i < TrailEffects.Length;i++)
      {
        TrailEffects[i].SetThrustEnabled(True);
        TrailEffects[i].SetThrust(ThrustAmount);
      }
    }
    DesiredOpacity = (RelVel.X - StreamerOpacityRamp.Min) / (StreamerOpacityRamp.Max - StreamerOpacityRamp.Min);
    DesiredOpacity = FClamp(DesiredOpacity,0.0,StreamerOpacityMax);
    MaxOpacityChange = DeltaTime * StreamerOpacityChangeRate;
    DeltaOpacity = DesiredOpacity - StreamerCurrentOpacity;
    DeltaOpacity = FClamp(DeltaOpacity, -MaxOpacityChange,MaxOpacityChange);
    if (  !bIsBehindView )
    {
      StreamerCurrentOpacity = 0.0;
    } else {
      StreamerCurrentOpacity += DeltaOpacity;
    }
    if ( StreamerCurrentOpacity < 0.01 )
    {
      NewStreamerActive = False;
    } else {
      NewStreamerActive = True;
    }

    for(i=0;i < StreamerEffect.Length;i++)
    {
      if ( NewStreamerActive )
      {
        if (  !StreamerActive )
        {
          t = TrailEmitter(StreamerEffect[i].Emitters[0]);
          t.ResetTrail();
        }
        StreamerEffect[i].Emitters[0].Disabled = False;
        StreamerEffect[i].Emitters[0].Opacity = StreamerCurrentOpacity;
      } else {
        StreamerEffect[i].Emitters[0].Disabled = True;
        StreamerEffect[i].Emitters[0].Opacity = 0.0;
      }
      //goto JL0241;
    }
    StreamerActive = NewStreamerActive;
  }

  Super.Tick(DeltaTime);
  JumpCountdown -= DeltaTime;
// JL0241:
  CheckJumpDuck();
  if ( DoBikeJump != OldDoBikeJump )
  {
    JumpCountdown = JumpDuration;
    OldDoBikeJump = DoBikeJump;
    if ( (Controller != Level.GetLocalPlayerController()) && EffectIsRelevant(Location,False) )
    {
      JumpEffect = Spawn(Class'HoverboardJumpEffect');
      JumpEffect.SetBase(self);
      ClientPlayForceFeedback(JumpForce);
    }
  }
  if ( Level.NetMode != 1 )
  {
    EnginePitch = 64.0 + VSize(Velocity) / MaxPitchSpeed * 64.0;
    SoundPitch = byte(FClamp(EnginePitch,64.0,128.0));
    if (  !bDropDetail )
    {
      bOverWater = False;
      KP = KarmaParams(KParams);
      for(i=0;i < KP.Repulsors.Length;i++)
      {
        if ( KP.Repulsors[i].bRepulsorOnWater )
        {
          bOverWater = True;
        }
      }

      for(i=0;i < BikeDust.Length;i++)
      {
        BikeDust[i].bDustActive = False;
        TraceStart = Location + (BikeDustOffset[i] >> Rotation);
        TraceEnd = TraceStart - BikeDustTraceDistance * vect(0.00,0.00,1.00);
        HitActor = Trace(HitLocation,HitNormal,TraceEnd,TraceStart,True);
        if ( HitActor == None )
        {
          BikeDust[i].UpdateHoverDust(False,0.0);
        } else {
          if ( bOverWater || (PhysicsVolume(HitActor) != None) && PhysicsVolume(HitActor).bWaterVolume )
          {
            BikeDust[i].SetDustColor(Level.WaterDustColor);
          } else {
            BikeDust[i].SetDustColor(Level.DustColor);
          }
          hitDist = VSize(HitLocation - TraceStart);
          BikeDust[i].SetLocation(HitLocation + 10 * HitNormal);
          BikeDustLastNormal[i] = Normal(3 * BikeDustLastNormal[i] + HitNormal);
          BikeDust[i].SetRotation(rotator(BikeDustLastNormal[i]));
          BikeDust[i].UpdateHoverDust(True,hitDist / BikeDustTraceDistance);
          if (  !BikeDust[i].bDustActive )
          {
            BikeDust[i].OldLocation = BikeDust[i].Location;
          }
          BikeDust[i].bDustActive = True;
        }
      }
    }
  }
}

function VehicleCeaseFire (bool bWasAltFire)
{
  Super.VehicleCeaseFire(bWasAltFire);
  if ( bWasAltFire )
  {
    bHoldingDuck = False;
  }
}

simulated function float ChargeBar ()
{
  if ( Level.TimeSeconds - JumpDelay < LastJumpTime )
  {
    return FMin((Level.TimeSeconds - LastJumpTime) / JumpDelay,0.9991);
  } else {
    return 0.9991;
  }
}

simulated function CheckJumpDuck ()
{
  local KarmaParams KP;
  local Emitter JumpEffect;
//  local Emitter DuckEffect;
  local bool bOnGround;
  local int i;

  KP = KarmaParams(KParams);
  bOnGround = False;

  for(i=0;i < KP.Repulsors.Length;i++)
  {
    if ( (KP.Repulsors[i] != None) && KP.Repulsors[i].bRepulsorInContact )
    {
      bOnGround = True;
    }
  }

  if ( (JumpCountdown <= 0.0) && (Rise > 0) && bOnGround &&  !bHoldingDuck && (Level.TimeSeconds - JumpDelay >= LastJumpTime) )
  {
    PlaySound(JumpSound,,1.0);
    if ( Role == 4 )
    {
      DoBikeJump =  !DoBikeJump;
    }
    if ( Level.NetMode != 1 )
    {
      JumpEffect = Spawn(class'HoverboardJumpEffect');
      JumpEffect.SetBase(self);
      ClientPlayForceFeedback(JumpForce);
    }
    if ( AIController(Controller) != None )
    {
      Rise = 0.0;
    }
    LastJumpTime = Level.TimeSeconds;
  } else {
    /*
    if ( (DuckCountdown <= 0.0) && ((Rise < 0) || bWeaponisAltFiring) )
    {
      if (  !bHoldingDuck )
      {
        bHoldingDuck = True;
        PlaySound(DuckSound,,1.0);
        if ( Level.NetMode != 1 )
        {
          DuckEffect = Spawn(class'ReaperBoardAttackEffect');
          DuckEffect.SetBase(self);
          PlayAnim('Spin',1.5);
        }
        if ( AIController(Controller) != None )
        {
          Rise = 0.0;
        }
        JumpCountdown = 0.0;
      }
    } else {
      bHoldingDuck = False;
    }

    */
  }
}

simulated function KApplyForce (out Vector Force, out Vector Torque)
{
  Super.KApplyForce(Force,Torque);
  if ( bDriving && (JumpCountdown > 0.0) )
  {
    Force += vect(0.00,0.00,1.00) * JumpForceMag;
  }
  if ( bDriving && bHoldingDuck )
  {
    Force += vect(0.00,0.00,-1.00) * DuckForceMag;
  }
}

static function StaticPrecache (LevelInfo L)
{
  Super.StaticPrecache(L);
  L.AddPrecacheStaticMesh(StaticMesh'HoverWing');
  L.AddPrecacheStaticMesh(StaticMesh'HoverChair');
  L.AddPrecacheStaticMesh(StaticMesh'Veh_Debris2');
  L.AddPrecacheStaticMesh(StaticMesh'Veh_Debris1');
  L.AddPrecacheStaticMesh(StaticMesh'PC_MantaJumpBlast');
  L.AddPrecacheMaterial(Texture'exp2_frames');
  L.AddPrecacheMaterial(Texture'exp1_frames');
  L.AddPrecacheMaterial(Texture'we1_frames');
  L.AddPrecacheMaterial(Texture'MuchSmoke1');
  L.AddPrecacheMaterial(Texture'NapalmSpot');
  L.AddPrecacheMaterial(Texture'SprayFire1');
  L.AddPrecacheMaterial(Texture'RocketTex0');
  L.AddPrecacheMaterial(Texture'JumpDuck');
  L.AddPrecacheMaterial(Texture'hovercraftFANSblurTEX');
  L.AddPrecacheMaterial(Texture'hoverCraftRED');
  L.AddPrecacheMaterial(Texture'hoverCraftBlue');
  L.AddPrecacheMaterial(Texture'NewHoverCraftNOcolor');
  L.AddPrecacheMaterial(Texture'AirBlast');
  L.AddPrecacheMaterial(Texture'SmokePanels2');
  L.AddPrecacheMaterial(Texture'GRADIENT_Fade');
}

simulated function UpdatePrecacheStaticMeshes ()
{
  Level.AddPrecacheStaticMesh(StaticMesh'HoverWing');
  Level.AddPrecacheStaticMesh(StaticMesh'HoverChair');
  Level.AddPrecacheStaticMesh(StaticMesh'Veh_Debris2');
  Level.AddPrecacheStaticMesh(StaticMesh'Veh_Debris1');
  Level.AddPrecacheStaticMesh(StaticMesh'PC_MantaJumpBlast');
  Level.AddPrecacheMaterial(Texture'hovercraftFANSblurTEX');
  Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials ()
{
  Level.AddPrecacheMaterial(Texture'exp2_frames');
  Level.AddPrecacheMaterial(Texture'exp1_frames');
  Level.AddPrecacheMaterial(Texture'we1_frames');
  Level.AddPrecacheMaterial(Texture'MuchSmoke1');
  Level.AddPrecacheMaterial(Texture'NapalmSpot');
  Level.AddPrecacheMaterial(Texture'SprayFire1');
  Level.AddPrecacheMaterial(Texture'RocketTex0');
  Level.AddPrecacheMaterial(Texture'JumpDuck');
  Level.AddPrecacheMaterial(Texture'hoverCraftRED');
  Level.AddPrecacheMaterial(Texture'hoverCraftBlue');
  Level.AddPrecacheMaterial(Texture'NewHoverCraftNOcolor');
  Level.AddPrecacheMaterial(Texture'AirBlast');
  Level.AddPrecacheMaterial(Texture'SmokePanels2');
  Level.AddPrecacheMaterial(Texture'GRADIENT_Fade');
  Super.UpdatePrecacheMaterials();
}


function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
    Driver.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}


defaultproperties
{
    MaxPitchSpeed=2000.00
    JumpDuration=0.10
    JumpForceMag=160.00
    JumpDelay=1.00
    DuckForceMag=70.00

    BikeDustOffset(0)=(X=5.000000,Y=0.000000,Z=10.000000)

    BikeDustTraceDistance=300.00
    JumpForce="HoverBikeJump"

    StreamerOpacityRamp=(Min=1200.000000,Max=1600.000000)

    StreamerOpacityChangeRate=1.00

    StreamerOpacityMax=0.70

    ThrusterOffsets(0)=(X=50.000000,Y=0.000000,Z=10.000000)

    HoverSoftness=0.18

    HoverPenScale=1.00

    HoverCheckDist=140.00

    UprightStiffness=40.00

    UprightDamping=100.00

    MaxThrustForce=15.00

    LongDamping=0.02

    MaxStrafeForce=10.00

    LatDamping=0.10

    TurnTorqueFactor=1000.00

    TurnTorqueMax=250.00

    TurnDamping=30.00

    MaxYawRate=3.50

    PitchTorqueFactor=-250.00

    PitchTorqueMax=-15.00

    PitchDamping=30.00

    RollTorqueTurnFactor=550.00

    RollTorqueStrafeFactor=400.00

    RollTorqueMax=25.00

    RollDamping=10.00

    StopThreshold=200.00

    bHasAltFire=False

//    RedSkin=Shader'AbaddonArchitecture-epic.Base.BloodyWallShader'
//    BlueSkin=Shader'AbaddonArchitecture-epic.Base.BloodyWallShader'
      RedSkin=Texture'HoverboardTex.HoverboardGrey'
      BlueSkin=texture'HoverboardTex.HoverboardGrey'

    IdleSound=Sound'IndoorAmbience.interior18'

//    StartUpSound=Sound'StartUp'
//    ShutDownSound=sound'Shutdown'
//   JumpSound=Sound'Jump'
//    DuckSound=Sound'spinattack'
     StartUpSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeStop01'
     JumpSound=sound'ONSVehicleSounds-S.HoverBike.HoverBikeJump05'
     DuckSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeTurbo01'



    StartUpForce="HoverBikeStartUp"
    ShutDownForce="HoverBikeShutDown"

    ViewShakeRadius=0.00

    DisintegrationHealth=0.00

//
//    DestructionAngularMomentum=
//
//    ExplosionSounds=[0]=()[1]=()[2]=()[3]=()[4]=()

    ExplosionDamage=0.00

    ExplosionRadius=0.00

    ExplosionMomentum=0.00

    DamagedEffectClass=None

    DamagedEffectScale=1.00

    bEjectPassengersWhenFlipped=True

    ImpactDamageMult=1.00

//    HeadlightCoronaOffset=[0]=()[1]=()

    HeadlightCoronaMaxSize=50.00

    bDrawDriverInTP=True

    bTurnInPlace=True

    bShowDamageOverlay=True

    bDrawMeshInFP=True

    bScriptedRise=True

    bShowChargingBar=True

    bCanCarryFlag=False

    EjectMomentum=-800.00

//    DrivePos=(X=-22.44,Y=-1.00,Z=50.00)
//    DrivePos=(X=-22.44,Y=-1.00,Z=60.00)
//    DrivePos=(X=-22.44,Y=-20.00,Z=60.00)
//    DrivePos=(X=-12.44,Y=-0.00,Z=60.00)
    DrivePos=(X=-12.44,Y=10.00,Z=60.00)

//    DriveRot=(Pitch=0,Yaw=8192,Roll=0)
    DriveRot=(Pitch=0,Yaw=16384,Roll=0)

    DriveAnim=HitF

    //ExitPositions=[0]=()[1]=()[2]=()[3]=()[4]=()[5]=()[6]=()[7]=()
     ExitPositions(0)=(Y=300.000000,Z=100.000000)
     ExitPositions(1)=(Y=-300.000000,Z=100.000000)
     ExitPositions(2)=(X=350.000000,Z=100.000000)
     ExitPositions(3)=(X=-350.000000,Z=100.000000)
     ExitPositions(4)=(X=-350.000000,Z=-100.000000)
     ExitPositions(5)=(X=350.000000,Z=-100.000000)
     ExitPositions(6)=(Y=300.000000,Z=-100.000000)
     ExitPositions(7)=(Y=-300.000000,Z=-100.000000)

    EntryRadius=150.00

    FPCamPos=(X=0.00,Y=0.00,Z=50.00),

    TPCamDistance=300.00

    TPCamLookat=(X=0.00,Y=0.00,Z=0.00),

    TPCamWorldOffset=(X=0.00,Y=0.00,Z=120.00),

    VehiclePositionString="on a Hoverboard"

    VehicleNameString="Hoverboard"

  //  RanOverDamageType=Class'DamTypeHoverboardHeadshot'

  //  CrushedDamageType=class'DamTypeHoverboardPancake'

    ObjectiveGetOutDist=10.00

    FlagBone=root

    FlagOffset=(X=0.00,Y=0.00,Z=45.00),

    FlagRotation=(Pitch=0,Yaw=32768,Roll=0),

//    HornSounds=[0]=()[1]=()

    bCanStrafe=True

    MeleeRange=-200.00


    HealthMax=1.00

    Health=1

    mesh=SkeletalMesh'HoverboardMesh.UT3Hoverboard'

    DrawScale=1.20

//    Skins=texture'HoverboardTex.HoverboardGrey'

    AmbientGlow=150

    SoundRadius=300.00


     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.150000
         KAngularDamping=0.000000
         KStartEnabled=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object

    KParams=KarmaParamsRBFull'Hoverboard.KParams0'

     bEjectDriver=true;
     MinRunOverSpeed=999999;
     /* OLD */
//     AirSpeed=7.000000
//     AccelRate=2.000000
//     GroundSpeed=7.00

     AirSpeed=5.000000
     AccelRate=0.5000000
     GroundSpeed=5.00

}

