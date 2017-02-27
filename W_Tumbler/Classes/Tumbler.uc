//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Tumbler extends ONSWheeledCraft;

var() float MaxPitchSpeed;
var bool bClientDoNitrous;
var float DoNitrousTime;
var float NitrousForce;
var int NitrousRemaining;
var() Sound NitrousSound;
var() Class<Emitter> TailPipeFireClass;
var Emitter TailPipeFire[2];
var() Vector TailPipeFireOffset[2];
var() Rotator TailPipeFireRotOffset[2];
var float PotentialFireTime;
var bool bPipeFlameOn;
var() Sound TailPipeFireSound;
var float TimeInAir;
var const float TimeInAirForHorn;
var float NitrousRechargeTime;
var float NitrousRechargeCounter;

replication
{
  unreliable if ( bNetDirty && (Role == 4) )
    bClientDoNitrous,NitrousRemaining;
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

function Pawn CheckForHeadShot (Vector loc, Vector ray, float AdditionalScale)
{
  local Vector X;
  local Vector Y;
  local Vector Z;

  GetAxes(Rotation,X,Y,Z);
  if ( (Driver != None) && Driver.IsHeadShot(loc,ray,AdditionalScale) )
  {
    return Driver;
  }
  return None;
}

simulated event PostBeginPlay ()
{
  Super.PostBeginPlay();
  if ( Level.NetMode != 1 )
  {
    TailPipeFire[0] = Spawn(TailPipeFireClass,self,,Location + (TailPipeFireOffset[0] >> Rotation));
    TailPipeFire[0].SetBase(self);
    TailPipeFire[0].SetRelativeRotation(TailPipeFireRotOffset[0]);
    TailPipeFire[1] = Spawn(TailPipeFireClass,self,,Location + (TailPipeFireOffset[1] >> Rotation));
    TailPipeFire[1].SetBase(self);
    TailPipeFire[1].SetRelativeRotation(TailPipeFireRotOffset[1]);
    EnablePipeFire(False);
  }
}

simulated function PostNetBeginPlay ()
{
  Super.PostNetBeginPlay();
  if ( Role == 4 )
  {
    PitchUpLimit = Default.PitchUpLimit;
    PitchDownLimit = Default.PitchDownLimit;
  }
}

function VehicleFire (bool bWasAltFire)
{
  if ( bWasAltFire )
  {
    Nitrous();
  } else {
    Super.VehicleFire(bWasAltFire);
  }
}

simulated event KApplyForce (out Vector Force, out Vector Torque)
{
  local int i;
  local float avgLoad;

  Super.KApplyForce(Force,Torque);
  if ( bClientDoNitrous && bVehicleOnGround )
  {
    avgLoad = 0.0;

    for(i = 0; i < Wheels.Length ; i++)
    {
      avgLoad += Wheels[i].TireLoad;
      i++;
    }
    avgLoad = avgLoad / Wheels.Length;
    avgLoad = FMin(avgLoad,20.0);
    avgLoad = avgLoad / 20.0;
    Force = Force + vector(Rotation);
    Force = Force + Normal(Force) * NitrousForce * avgLoad;
  }
}

function Nitrous ()
{
  if ( (NitrousRemaining > 0) &&  !bClientDoNitrous )
  {
    NitrousRechargeCounter = 0.0;
    PlaySound(NitrousSound,SLOT_Misc,1.0);
    bClientDoNitrous = True;
    NitrousRemaining--;
  }
}

simulated event Timer ()
{
  bClientDoNitrous = False;
  EnablePipeFire(bClientDoNitrous);
}

simulated event Tick (float DeltaTime)
{
  Super.Tick(DeltaTime);
  if ( bClientDoNitrous != bPipeFlameOn )
  {
    EnablePipeFire(bClientDoNitrous);
    if ( bClientDoNitrous )
    {
      SetTimer(DoNitrousTime,False);
    }
  }
  if ( Level.NetMode != 1 )
  {
    if (  !bVehicleOnGround )
    {
      TimeInAir += DeltaTime;
    } else {
      TimeInAir = 0.0;
    }
  }
  if ( Role == 4 )
  {
    NitrousRechargeCounter += DeltaTime;
    if ( NitrousRechargeCounter > NitrousRechargeTime )
    {
      if ( NitrousRemaining < 1 )
      {
        NitrousRemaining++;
      }
      NitrousRechargeCounter = 0.0;
    }
  }
}

function int LimitPitch (int Pitch)
{
  return Super(Pawn).LimitPitch(Pitch);
}

simulated event Destroyed ()
{
  if ( Level.NetMode != 1 )
  {
    TailPipeFire[0].Destroy();
    TailPipeFire[1].Destroy();
  }
  Super.Destroyed();
}

simulated function EnablePipeFire (bool bEnable)
{
  local int i;
  local int j;

  if ( Level.NetMode != 1 )
  {
    for(i = 0;i < 2;i++)
    {
      j = 0;
      for(j=0; j < TailPipeFire[i].Emitters.Length; j++)
      {
        TailPipeFire[i].Emitters[j].Disabled =  !bEnable;
      }
    }
  }
  bPipeFlameOn = bEnable;
}

function ServerAwardNitrous (int Count)
{
  NitrousRemaining += Count;
}

simulated function int DaredevilToNitrousAward (int InDaredevilPoints)
{
  return Max(2,InDaredevilPoints / 10);
}

simulated event OnDaredevil ()
{
  local PlayerController PC;
  local TeamPlayerReplicationInfo PRI;

  PC = PlayerController(Controller);
  if ( PC != None )
  {
    if ( Role == 4 )
    {
      PC.ReceiveLocalizedMessage(DaredevilMessageClass,DaredevilToNitrousAward(DaredevilPoints),None,None,self);
      PRI = TeamPlayerReplicationInfo(PC.PlayerReplicationInfo);
      if ( PRI != None )
      {
        PRI.DaredevilPoints += DaredevilPoints;
      }
      ServerAwardNitrous(DaredevilToNitrousAward(DaredevilPoints));
    }
  }
}

static function StaticPrecache (LevelInfo L)
{
  Super.StaticPrecache(L);
  L.AddPrecacheStaticMesh(StaticMesh'RVgun');
  L.AddPrecacheStaticMesh(StaticMesh'RVrail');
  L.AddPrecacheStaticMesh(StaticMesh'Rvtire');
  L.AddPrecacheStaticMesh(StaticMesh'Veh_Debris2');
  L.AddPrecacheStaticMesh(StaticMesh'Veh_Debris1');
  L.AddPrecacheMaterial(Texture'exp2_frames');
  L.AddPrecacheMaterial(Texture'exp1_frames');
  L.AddPrecacheMaterial(Texture'we1_frames');
  L.AddPrecacheMaterial(Texture'SmokeReOrdered');
  L.AddPrecacheMaterial(Texture'NapalmSpot');
  L.AddPrecacheMaterial(Texture'SprayFire1');
  L.AddPrecacheMaterial(Combiner'RVcolorRED');
  L.AddPrecacheMaterial(Texture'NEWrvNoCOLOR');
  L.AddPrecacheMaterial(Texture'ReflectionTexture');
  L.AddPrecacheMaterial(Texture'RVnewGUNtex');
  L.AddPrecacheMaterial(Texture'MuzzleSpray');
  L.AddPrecacheMaterial(Texture'DustyCloud2');
  L.AddPrecacheMaterial(Texture'dirtKICKTEX');
  L.AddPrecacheMaterial(Texture'GRADIENT_Fade');
}

simulated function UpdatePrecacheStaticMeshes ()
{
  Level.AddPrecacheStaticMesh(StaticMesh'RVgun');
  Level.AddPrecacheStaticMesh(StaticMesh'RVrail');
  Level.AddPrecacheStaticMesh(StaticMesh'Rvtire');
  Level.AddPrecacheStaticMesh(StaticMesh'Veh_Debris2');
  Level.AddPrecacheStaticMesh(StaticMesh'Veh_Debris1');
  Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials ()
{
  Level.AddPrecacheMaterial(Texture'exp2_frames');
  Level.AddPrecacheMaterial(Texture'exp1_frames');
  Level.AddPrecacheMaterial(Texture'we1_frames');
  Level.AddPrecacheMaterial(Texture'SmokeReOrdered');
  Level.AddPrecacheMaterial(Texture'NapalmSpot');
  Level.AddPrecacheMaterial(Texture'SprayFire1');
  Level.AddPrecacheMaterial(Combiner'RVcolorRED');
  Level.AddPrecacheMaterial(Texture'NEWrvNoCOLOR');
  Level.AddPrecacheMaterial(Texture'RVblades');
  Level.AddPrecacheMaterial(Texture'ReflectionTexture');
  Level.AddPrecacheMaterial(Texture'RVnewGUNtex');
  Level.AddPrecacheMaterial(Texture'MuzzleSpray');
  Level.AddPrecacheMaterial(Texture'DustyCloud2');
  Level.AddPrecacheMaterial(Texture'dirtKICKTEX');
  Level.AddPrecacheMaterial(Texture'RVcolorBlue');
  Level.AddPrecacheMaterial(Texture'GRADIENT_Fade');
  Level.AddPrecacheMaterial(Texture'link_spark_green');
  Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     DoNitrousTime=3.000000
     NitrousForce=150.000000
     NitrousRemaining=2
     NitrousSound=Sound'GSounds.Tumbler.TumblerThruster'
     TailPipeFireClass=Class'W_Tumbler.Emitter_JetExhaust'
     TailPipeFireOffset(0)=(X=-138.000000,Z=18.000000)
     TailPipeFireRotOffset(0)=(Yaw=32768)
     TailPipeFireRotOffset(1)=(Yaw=32768)
     NitrousRechargeTime=8.000000
     WheelSoftness=0.030000
     WheelPenScale=1.200000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=1.750000
     WheelHandbrakeSlip=0.350000
     WheelHandbrakeFriction=1.000000
     WheelSuspensionTravel=15.000000
     WheelSuspensionOffset=-4.000000
     WheelSuspensionMaxRenderTravel=15.000000
     FTScale=0.030000
     ChassisTorqueScale=0.400000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=8.000000),(InVal=1000000000.000000,OutVal=8.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2500.000000)))
     GearRatios(0)=-0.500000
     GearRatios(1)=0.350000
     GearRatios(2)=0.650000
     GearRatios(3)=0.850000
     GearRatios(4)=1.100000
     TransRatio=0.150000
     ChangeUpPoint=3000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=75.000000
     SteerSpeed=180.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.150000
     IdleRPM=500.000000
     EngineRPMSoundRange=9000.000000
     SteerBoneName="SteeringWheel"
     SteerBoneMaxAngle=90.000000
     RevMeterScale=8000.000000
     BrakeLightOffset(0)=(X=-96.000000,Y=6.000000,Z=53.000000)
     BrakeLightOffset(1)=(X=-96.000000,Y=-6.000000,Z=53.000000)
     BrakeLightMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     DaredevilThreshInAirSpin=90.000000
     DaredevilThreshInAirTime=2.000000
     DaredevilThreshInAirDistance=21.000000
     bAllowChargingJump=True
     bAllowBigWheels=True
     MaxJumpForce=480000.000000
     MaxJumpSpin=5.000000
     JumpChargeTime=0.150000
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     IdleSound=Sound'GSounds.Tumbler.TumblerIdle'
     StartUpSound=Sound'GSounds.Tumbler.TumblerStart'
     ShutDownSound=Sound'GSounds.Tumbler.TumblerShutoff'
     StartUpForce="RVStartUp"
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.RVDead'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathPRV'
     DisintegrationHealth=-100.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectScale=1.200000
     DamagedEffectOffset=(X=-95.000000,Y=6.500000,Z=25.000000)
     ImpactDamageMult=0.000000
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=30.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVprojector'
     HeadlightProjectorOffset=(X=90.000000,Z=7.000000)
     HeadlightProjectorRotation=(Pitch=-1000)
     HeadlightProjectorScale=0.300000
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RRWheel"
         BoneOffset=(X=-15.000000)
         WheelRadius=34.000000
         SupportBoneName="RRStrut"
     End Object
     Wheels(0)=SVehicleWheel'W_Tumbler.Tumbler.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LRWheel"
         BoneOffset=(X=15.000000)
         WheelRadius=34.000000
         SupportBoneName="LRStrut"
     End Object
     Wheels(1)=SVehicleWheel'W_Tumbler.Tumbler.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RFWheel"
         BoneOffset=(X=-15.000000)
         WheelRadius=34.000000
         SupportBoneName="RFrontStrut"
     End Object
     Wheels(2)=SVehicleWheel'W_Tumbler.Tumbler.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LFWheel"
         BoneOffset=(X=15.000000)
         WheelRadius=34.000000
         SupportBoneName="LfrontStrut"
     End Object
     Wheels(3)=SVehicleWheel'W_Tumbler.Tumbler.LFWheel'

     VehicleMass=4.000000
     bDrawDriverInTP=True
     bDrawMeshInFP=True
     bHasHandbrake=True
     bSeparateTurretFocus=True
     DrivePos=(X=-2.000000,Y=-24.000000,Z=55.500000)
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryRadius=180.000000
     FPCamPos=(Y=-24.000000,Z=40.000000)
     CenterSpringForce="SpringONSSRV"
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     DriverDamageMult=0.030000
     VehiclePositionString="in the Tumbler"
     VehicleNameString="Tumbler"
     RanOverDamageType=Class'Onslaught.DamTypeRVRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypeRVPancake'
     MaxDesireability=0.400000
     ObjectiveGetOutDist=1500.000000
     GroundSpeed=900.000000
     HealthMax=800.000000
     Health=800
     Mesh=SkeletalMesh'GAnimsV3A.Tumbleranim'
     DrawScale=0.830000
     SoundVolume=215
     CollisionRadius=100.000000
     CollisionHeight=40.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(X=-0.250000,Z=-0.400000)
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'W_Tumbler.Tumbler.KParams0'

}
