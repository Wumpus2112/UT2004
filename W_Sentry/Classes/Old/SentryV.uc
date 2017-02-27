//=============================================================================
// ASVehicle_Sentinel
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class SentryV extends ONSVehicle;

/**************** AS Turret **********************/

// Static base
var		class<ASTurret_Base>	TurretBaseClass;
var		ASTurret_Base			TurretBase;
var		Rotator					OriginalRotation;

// Swivel (follows Turret's rotation Yaw only)
var		class<ASTurret_Base>	TurretSwivelClass;
var		ASTurret_Base			TurretSwivel;

// Movement
var float		YawAccel, PitchAccel;

var()	const	float	RotationInertia;
var()	const	Range	RotPitchConstraint;		// Min=0d,-90d  Max=0d,+90d  16384=0d 0=90d
var()	const	float	RotationSpeed;
var()			vector  CamAbsLocation, CamRelLocation, CamDistance;


/**************** Sentinel Floor**********************/

Var bool	bActive, bOldActive;
var bool	bSpawnCampProtection;	// when true, sentinels are more powerful
var Sound	OpenCloseSound;


/**************** Sentry **********************/
var float secondsToLive;


Replication
{
	reliable if ( (bNetInitial || bNetDirty) && Role==ROLE_Authority )
		bActive;
}



simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	if ( bSpawnCampProtection )
		RotationRate *= 100;

}

simulated function PostNetReceive()
{
	super.PostNetReceive();

	if ( bActive != bOldActive )
	{
		bOldActive = bActive;

		if ( bActive )
			PlayOpening();
		else
			PlayClosing();
	}
}

/* awake sleeping sentinel */
function AwakeSentinel()
{
	ASSentinelController(Controller).Awake();
}

function bool Awake() { return false; }
function bool GoToSleep() { return false; }
simulated function PlayClosing();
simulated function PlayOpening();

simulated function PlayFiring(optional float Rate, optional name FiringMode )
{
	PlayAnim('Fire', 0.75);
}

simulated function PlayIdleOpened()
{
	PlayAnim('IdleOpen', 1, 0.0);

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( TurretBase != None && TurretBase.Mesh != None )
			TurretBase.GotoState('Active');

		if ( TurretSwivel != None && TurretSwivel.Mesh != None )
			TurretSwivel.GotoState('Active');
	}
}

simulated function PlayIdleClosed()
{
	PlayAnim('IdleClosed', 1, 0.0);

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( TurretBase != None && TurretBase.Mesh != None )
			TurretBase.GotoState('Sleeping');

		if ( TurretSwivel != None && TurretSwivel.Mesh != None )
			TurretSwivel.GotoState('Sleeping');
	}
}


auto state Sleeping
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, class<DamageType> damageType)
	{
		if ( Role == Role_Authority )
			AwakeSentinel();
	}

	simulated event AnimEnd( int Channel )
	{
		PlayIdleClosed();
	}

	function bool Awake()
	{
		if ( Role == Role_Authority )
			bActive = true;

		PlayOpening();

		return true;
	}

	simulated function PlayOpening()
	{
		PlayAnim('Open', 0.33, 0.0);

		if ( Level.NetMode != NM_DedicatedServer )
		{
			if ( OpenCloseSound != None )
				PlaySound( OpenCloseSound );

			if ( TurretBase != None && TurretBase.Mesh != None )
				TurretBase.GotoState('Opening');

			if ( TurretSwivel != None && TurretSwivel.Mesh != None )
				TurretSwivel.GotoState('Opening');
		}

		GotoState('Opening');
	}

Begin:
	if ( bActive )
		PlayOpening();
	else
		PlayIdleClosed();
}

state Active
{
	simulated event AnimEnd( int Channel )
	{
		PlayIdleOpened();
	}

	function bool GoToSleep()
	{
		if ( Role == Role_Authority )
			bActive = false;

		PlayClosing();

		return true;
	}

	simulated function PlayClosing()
	{
		PlayAnim('Close', 0.33, 0.0);

		if ( Level.NetMode != NM_DedicatedServer )
		{
			if ( OpenCloseSound != None )
				PlaySound( OpenCloseSound );

			if ( TurretBase != None && TurretBase.Mesh != None )
				TurretBase.GotoState('Closing');

			if ( TurretSwivel != None && TurretSwivel.Mesh != None )
				TurretSwivel.GotoState('Closing');
		}
		GotoState('Closing');
	}

Begin:
	PlayIdleOpened();
}

state Closing
{
	simulated event AnimEnd( int Channel )
	{
		if ( Role == Role_Authority )
			ASSentinelController(Controller).AnimEnded();
		GotoState('Sleeping');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType);
}

state Opening
{
	simulated event AnimEnd( int Channel )
	{
		if ( Role == Role_Authority )
			ASSentinelController(Controller).AnimEnded();
		GotoState('Active');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType);
}

defaultproperties
{
    Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretBase'
//     DefaultWeaponClassName="UT2k4Assault.Weapon_Sentinel"
     bNonHumanControl=True

         AutoTurretControllerClass=class'W_Sentry.SentryController'

//     AutoTurretControllerClass=Class'UT2k4Assault.ASSentinelController'
     //ControllerClass=Class'UT2k4Assault.ASSentinelController'

     VehicleNameString="Sentinel"
     bNoTeamBeacon=True
     HealthMax=1000.000000
     Health=1000
     TransientSoundVolume=0.750000
     TransientSoundRadius=512.000000
     bNetNotify=True

     DrawScale=0.500000

     bAutoTurret=true;

     secondsToLive=25.0





     Begin Object Class=KarmaParamsRBFull Name=KParams0
        KInertiaTensor[0]=1.0
        KInertiaTensor[3]=3.0
        KInertiaTensor[5]=3.50
        KCOMOffset=(X=-0.250,Y=0.0,Z=0.0)
        KLinearDamping=0.0
        KAngularDamping=0.0
        KStartEnabled=true
        bKNonSphericalInertia=true
        KActorGravScale=0.0
        bHighDetailOnly=false
        bClientOnly=false
        bKDoubleTickRate=true
        bKStayUpright=true
        bKAllowRotate=true
        bDestroyOnWorldPenetrate=true
        bDoSafetime=true
        KFriction=0.50
        KImpactThreshold=300.0
     End Object
     KParams=KarmaParamsRBFull'W_Sentry.SentryV.KParams0'
}
