//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WumpusScud extends ONSWheeledCraft;

#exec OBJ LOAD FILE=ONSBPTextures.utx

var float   YawAccel, PitchAccel;
var float   ClientUpdateTime;
var float	StartDrivingTime;	// AI Hint
var Rotator LastAim;
var bool    bJustDeployed;
var ONSMortarCamera MortarCamera;

var float LastLocalMsgTime;
var string ArtiLockOnClassString;

replication
{
    reliable if (Role == ROLE_Authority)
        MortarCamera;

	reliable if (Role < ROLE_Authority)
        ServerAim;
}

function bool IsArtillery()
{
	return true;
}

function bool IsDeployed()
{
	local ONSArtilleryCannon Cannon;

	Cannon = ONSArtilleryCannon(Weapons[ActiveWeapon]);
	if ( (Cannon != None) && (Cannon.MortarCamera != None) )
		return true;
	if ( Level.TimeSeconds - Cannon.LastCameraLaunch > Cannon.CameraLaunchWait )
		return true;
	return false;
}

function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);
	StartDrivingTime = Level.TimeSeconds;
}

function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local SquadAI Squad;

	Squad = SquadAI(S);

	if ( Squad.GetOrders() == 'Defend' )
		return 0;

	return super.BotDesireability(S,TeamIndex,Objective);
}

function VehicleFire(bool bWasAltFire)
{
	local vector TargetDir;
	local rotator AimRot;

	if ( bWasAltFire )
	{
		if (  MortarCamera != None )
		{
			if ( !MortarCamera.bDeployed )
			{
				if ( AIController(Instigator.Controller) != None )
				{
					return;
				}
				MortarCamera.Deploy();
				CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
			}
			else
			{
				if ( AIController(Instigator.Controller) != None )
					bWasAltFire = false;
				else
					MortarCamera.Destroy();
			}
			return;
		}
		else if ( (AIController(Instigator.Controller) != None) && (Controller.Target != None) )
		{
			TargetDir = Controller.Target.Location - Location;
			TargetDir.Z = 0;
			AimRot = Weapons[ActiveWeapon].CurrentAim;
			AimRot.Pitch = 0;
			if ( (Normal(TargetDir) Dot Vector(AimRot)) < 0.9 )
			{
				return;
			}
		}
	}
	Super.VehicleFire(bWasAltFire);
}


function AltFire( optional float F )
{
	local bool bHasCamera;

	bHasCamera = ( MortarCamera != None );

	Super.AltFire(F);
    if ( MortarCamera != None )
    {
		if ( Role < ROLE_Authority  && !MortarCamera.bDeployed )
		{
			MortarCamera.Deploy();
			CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
			bJustDeployed = true;
		}
	}
	if ( bHasCamera )
		bWeaponIsAltFiring = false;
}

function ServerAim(int NewYaw)
{
    CustomAim.Yaw = NewYaw;
    CustomAim.Pitch = Default.CustomAim.Pitch;
    CustomAim.Roll = Default.CustomAim.Roll;
}

simulated function RawInput(float DeltaTime,
							float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
							float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
	if (PlayerController(Controller) != None)
	{
        if (aStrafe > 0)
            YawAccel = 1.0;
        if (aStrafe < 0)
            YawAccel = -1.0;
        if (aForward > 0)
            PitchAccel = 1.0;
        if (aForward < 0)
            PitchAccel = -1.0;
    }
}

function int LimitPitch(int pitch)
{
	if (ActiveWeapon >= Weapons.length)
		return Super.LimitPitch(pitch);

	if (ONSArtilleryCannon(Weapons[ActiveWeapon]) != None && ONSArtilleryCannon(Weapons[ActiveWeapon]).MortarCamera != None)
	{
    	pitch = pitch & 65535;

        if (pitch > 2500 && pitch < 49153)
        {
            if (pitch - 2500 < 49153 - pitch)
                pitch = 2500;
            else
                pitch = 49153;
        }
        return pitch;
    }

	return Weapons[ActiveWeapon].LimitPitch(pitch, Rotation);
}

simulated function Tick(float DT)
{
	local DestroyableObjective ObjectiveTarget;

	Super.Tick(DT);

	if ( AIController(Controller) != None )
	{
		bCustomAiming = true;
        CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
		if ( Controller.Target != None )
			CustomAim.Yaw = Rotator(Controller.Target.Location - Location).Yaw;
		LastAim = CustomAim;
		if ( MortarCamera != None )
		{
			bAltFocalPoint = true;
			if ( Controller.Target != None )
			{
				if ( MortarCamera.bDeployed )
				{
					if ( ShootTarget(Controller.Target) != None )
						ObjectiveTarget = DestroyableObjective(Controller.Target.Owner);
					else
						ObjectiveTarget = DestroyableObjective(Controller.Target);
				}
				if ( (ObjectiveTarget != None) && !ObjectiveTarget.LegitimateTargetOf(Bot(Controller)) )
				{
					MortarCamera.Destroy();
					ONSArtilleryCannon(Weapons[ActiveWeapon]).AllowCameraLaunch();
					Weapons[ActiveWeapon].FireCountDown = Weapons[ActiveWeapon].AltFireInterval;
				}
				else
				{
					Throttle = 0.0;
					Steering = 0.0;
				}
			}
			else
			{
				bAltFocalPoint = false;
				MortarCamera.Destroy();
				ONSArtilleryCannon(Weapons[ActiveWeapon]).AllowCameraLaunch();
				Weapons[ActiveWeapon].FireCountDown = Weapons[ActiveWeapon].AltFireInterval;
			}
		}
		else
			bAltFocalPoint = false;
	}
    else if (MortarCamera != None)
    {
	    bCustomAiming = True;

        CustomAim.Pitch = Default.CustomAim.Pitch;
        CustomAim.Roll = Default.CustomAim.Roll;

        if ( IsLocallyControlled() && IsHumanControlled() )
        {
            if ( PlayerController(Controller) != None && PlayerController(Controller).ViewTarget != MortarCamera )
                PlayerController(Controller).SetViewTarget(MortarCamera);

            CustomAim.Yaw += YawAccel * 8192 * DT;

            if (Weapons[ActiveWeapon] != None && ONSArtilleryCannon(Weapons[ActiveWeapon]) != None)
                ONSArtilleryCannon(Weapons[ActiveWeapon]).SetWeaponCharge(FClamp(ONSArtilleryCannon(Weapons[ActiveWeapon]).WeaponCharge + (PitchAccel * DT), 0.0, 0.999));

            if (bCustomAiming && bJustDeployed || ((Level.TimeSeconds - ClientUpdateTime > 0.0222) && CustomAim != LastAim))
            {
                ClientUpdateTime = Level.TimeSeconds;
                ServerAim(CustomAim.Yaw);
                LastAim = CustomAim;
                bJustDeployed = false;
            }

            YawAccel = 0.0;
            PitchAccel = 0.0;
        }

        Throttle = 0.0;
        Steering = 0.0;
    }
    else
    {
        bCustomAiming = False;
        if (IsLocallyControlled() && Weapons[ActiveWeapon] != None)
            CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
    }
}

simulated function PrevWeapon()
{
    if (MortarCamera != None && Weapons[ActiveWeapon] != None && ONSArtilleryCannon(Weapons[ActiveWeapon]) != None)
        ONSArtilleryCannon(Weapons[ActiveWeapon]).SetWeaponCharge(FMin(ONSArtilleryCannon(Weapons[ActiveWeapon]).WeaponCharge + 0.025, 0.999));
    else
        Super.PrevWeapon();
}

simulated function NextWeapon()
{
    if (MortarCamera != None && Weapons[ActiveWeapon] != None && ONSArtilleryCannon(Weapons[ActiveWeapon]) != None)
        ONSArtilleryCannon(Weapons[ActiveWeapon]).SetWeaponCharge(FMax(ONSArtilleryCannon(Weapons[ActiveWeapon]).WeaponCharge - 0.025, 0.0));
    else
        Super.NextWeapon();
}

simulated function actor AlternateTarget()
{
    return MortarCamera;
}

event bool VerifyLock(actor Aggressor, out actor NewTarget)
{
	local	class<LocalMessage>	LockOnClass;

	if (MortarCamera != None && !FastTrace(Location, Aggressor.Location))
	{
        NewTarget = MortarCamera;
        return False;
    }

	// Lock has switched from the Camera to the SPMA, notify the Avril Controller

	if (Aggressor.Instigator!=None && Aggressor.Instigator.Controller !=None &&
			PlayerController(Aggressor.Instigator.Controller) != none)
	{
	 	if (Level.TimeSeconds > LastLocalMsgTime + LockWarningInterval)
	 	{
			LockOnClass = class<LocalMessage>(DynamicLoadObject(ArtiLockOnClassString, class'class'));
			PlayerController(Aggressor.Instigator.Controller).ReceiveLocalizedMessage(LockOnClass, 32);
		}
	}

    return True;
}

simulated event Destroyed()
{
    if (MortarCamera != None)
        MortarCamera.TakeDamage(1, None, vect(0,0,0), vect(0,0,0), class'DamageType');

    Super.Destroyed();
}

function DriverLeft()
{
    if (MortarCamera != None)
        MortarCamera.TakeDamage(1, None, vect(0,0,0), vect(0,0,0), class'DamageType');

    Super.DriverLeft();
}

event ApplyFireImpulse(bool bAlt)
{
	if ( AIController(Instigator.Controller) != None )
	{
		if ( Controller.Target != None )
		{
			Weapons[ActiveWeapon].CalcWeaponFire();
			Weapons[ActiveWeapon].WeaponFireRotation = Rotator(Controller.Target.Location - Weapons[ActiveWeapon].WeaponFireLocation);
			Weapons[ActiveWeapon].WeaponFireRotation.Pitch = 10000;
			Weapons[ActiveWeapon].WeaponFireLocation.Z = Location.Z + 500;
		}
	}
	Super.ApplyFireImpulse(bAlt);
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function ShouldTargetMissile(Projectile P)
{
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.LargeShell');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Target');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Mini_Shell');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.TargetNo');

    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMAGreen');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.MuzzleSpray');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMATan');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Missile');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Smoke');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.ExploTrans');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1Alpha');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.seexpt');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.ArtilleryCamTexture');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test2');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Fire');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'BenTex01.textures.SmokePuff01');
    L.AddPrecacheMaterial(Material'ArboreaTerrain.ground.flr02ar');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlphaNo');
    L.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas28go');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.LargeShell');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Target');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Mini_Shell');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.TargetNo');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMAGreen');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.MuzzleSpray');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMATan');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Missile');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Smoke');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.ExploTrans');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1Alpha');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.seexpt');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.ArtilleryCamTexture');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test2');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Fire');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'BenTex01.textures.SmokePuff01');
    Level.AddPrecacheMaterial(Material'ArboreaTerrain.ground.flr02ar');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlphaNo');
    Level.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas28go');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     ArtiLockOnClassString="Onslaught.ONSOnslaughtMessage"
     WheelSoftness=0.060000
     WheelPenScale=1.500000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=1.500000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.150000
     WheelSuspensionTravel=25.000000
     WheelSuspensionOffset=-10.000000
     WheelSuspensionMaxRenderTravel=25.000000
     FTScale=0.030000
     ChassisTorqueScale=1.250000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=35.000000),(InVal=700.000000,OutVal=35.000000),(InVal=800.000000,OutVal=10.000000),(InVal=1000000000.000000,OutVal=10.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2500.000000)))
     GearRatios(0)=-0.500000
     GearRatios(1)=0.400000
     GearRatios(2)=0.650000
     GearRatios(3)=0.850000
     GearRatios(4)=1.100000
     TransRatio=0.110000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=110.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.200000
     IdleRPM=500.000000
     EngineRPMSoundRange=10000.000000
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=4000.000000
     bMakeBrakeLights=True
     BrakeLightOffset(0)=(X=46.000000,Y=47.000000,Z=45.000000)
     BrakeLightOffset(1)=(X=46.000000,Y=-47.000000,Z=45.000000)
     BrakeLightMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     DaredevilThreshInAirSpin=90.000000
     DaredevilThreshInAirTime=1.200000
     bDoStuntInfo=True
     bAllowBigWheels=True
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     DriverWeapons(0)=(WeaponClass=Class'WumpusScud.ScudRocketPack',WeaponBone="CannonAttach")
     PassengerWeapons(0)=(WeaponPawnClass=Class'OnslaughtBP.ONSArtillerySideGunPawn',WeaponBone="SideGunAttach")
     CustomAim=(Pitch=12000)
     RedSkin=Texture'ONSBPTextures.Skins.SPMATan'
     BlueSkin=Texture'ONSBPTextures.Skins.SPMAGreen'
     IdleSound=Sound'ONSVehicleSounds-S.PRV.PRVEng01'
     StartUpSound=Sound'ONSBPSounds.Artillery.EngineRampUp'
     ShutDownSound=Sound'ONSBPSounds.Artillery.EngineRampDown'
     StartUpForce="PRVStartUp"
     ShutDownForce="PRVShutDown"
     DestroyedVehicleMesh=StaticMesh'ONSBP_DestroyedVehicles.SPMA.DestroyedSPMA'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'OnslaughtBP.ONSArtilleryDeathExp'
     DisintegrationHealth=-100.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectScale=1.200000
     DamagedEffectOffset=(X=250.000000,Y=20.000000,Z=50.000000)
     FireImpulse=(X=-110000.000000)
     bHasFireImpulse=True
     ImpactDamageMult=0.001000
     HeadlightCoronaOffset(0)=(X=290.000000,Y=50.000000,Z=40.000000)
     HeadlightCoronaOffset(1)=(X=290.000000,Y=-50.000000,Z=40.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=70.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.NEWprvGroup.PRVprojector'
     HeadlightProjectorOffset=(X=290.000000,Z=40.000000)
     HeadlightProjectorRotation=(Pitch=-1500)
     HeadlightProjectorScale=0.650000
     Begin Object Class=SVehicleWheel Name=RWheel1
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Steered
         BoneName="Wheel_Right01"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionRight01"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'OnslaughtBP.ONSArtillery.RWheel1'

     Begin Object Class=SVehicleWheel Name=LWheel1
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Steered
         BoneName="Wheel_Left01"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionLeft01"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'OnslaughtBP.ONSArtillery.LWheel1'

     Begin Object Class=SVehicleWheel Name=RWheel2
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="Wheel_Right02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionRight02"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'OnslaughtBP.ONSArtillery.RWheel2'

     Begin Object Class=SVehicleWheel Name=LWheel2
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="Wheel_Left02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionLeft02"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'OnslaughtBP.ONSArtillery.LWheel2'

     Begin Object Class=SVehicleWheel Name=RWheel3
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Inverted
         BoneName="Wheel_Right03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionRight03"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(4)=SVehicleWheel'OnslaughtBP.ONSArtillery.RWheel3'

     Begin Object Class=SVehicleWheel Name=LWheel3
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Inverted
         BoneName="Wheel_Left03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionLeft03"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(5)=SVehicleWheel'OnslaughtBP.ONSArtillery.LWheel3'

     VehicleMass=4.000000
     bDrawDriverInTP=True
     bDrawMeshInFP=True
     bHasHandbrake=True
     bDriverHoldsFlag=False
     DrivePos=(X=145.000000,Y=-30.000000,Z=75.000000)
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryPosition=(X=40.000000,Y=-60.000000,Z=10.000000)
     EntryRadius=320.000000
     FPCamPos=(X=160.000000,Y=-30.000000,Z=75.000000)
     TPCamDistance=375.000000
     TPCamLookat=(X=100.000000,Y=-30.000000,Z=-100.000000)
     TPCamWorldOffset=(Z=350.000000)
     TPCamDistRange=(Min=200.000000)
     MomentumMult=2.000000
     DriverDamageMult=0.100000
     VehiclePositionString="in a Stryker"
     VehicleNameString="Stryker"
     RanOverDamageType=Class'Onslaught.DamTypePRVRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypePRVPancake'
     MaxDesireability=0.600000
     ObjectiveGetOutDist=1500.000000
     FlagBone="Body"
     FlagOffset=(X=200.000000,Z=150.000000)
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSBPSounds.Artillery.SPMAHorn'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn04'
     VehicleIcon=(Material=Texture'AS_FX_TX.Icons.OBJ_HellBender',bIsGreyScale=True)
     GroundSpeed=840.000000
     HealthMax=600.000000
     Health=600
     Mesh=SkeletalMesh'ONSBPAnimations.ArtilleryMesh'
     SoundVolume=200
     SoundRadius=220.000000
     CollisionRadius=260.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=1.500000,Z=-0.500000)
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
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsRBFull'OnslaughtBP.ONSArtillery.KParams0'

}
