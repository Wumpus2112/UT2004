class ControllerSentryAS extends ControllerSentryBase;

var float	StartSearchTime;
var rotator	LastRotation;

function AnimEnded();
function Awake();
function GoToSleep();


function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
	if ( (FRand() < 0.45) && (Enemy != None) && (Enemy.Controller != None) )
		Enemy.Controller.ReceiveWarning(Pawn, -1, vector(Rotation));

    return Rotation;
}

auto state Sleeping
{
	event SeePlayer(Pawn SeenPlayer)
	{
	    log("AS-Sleeping:event SeePlayer: "@SeenPlayer.Class);
		if ( IsTargetRelevant( SeenPlayer ) )
			Awake();
	}

	function Awake()
	{
	    log("ControllerSentryBase.Sleeping:Awake.Pawn"@Pawn.class);

		LastRotation = Rotation;
		if ( Sentry(Pawn).Awake() )
			GotoState('Opening');
	}

	function ScanRotation()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, Dir;
		local float BestDist, Dist;
		local rotator Pick;

		DesiredRotation.Yaw = Rotation.Yaw + 16384 + Rand(32768);
		Dir = vector(DesiredRotation);

		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		BestDist = vsize(HitLocation - Pawn.Location);
		Pick = DesiredRotation;

		DesiredRotation.Yaw += 32768;
		Dir = vector(DesiredRotation);
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		Dist = vsize(HitLocation - Pawn.Location);
		if ( Dist > BestDist )
		{
			BestDist = Dist;
			Pick = DesiredRotation;
		}

		DesiredRotation.Yaw += 16384;
		Dir = vector(DesiredRotation);
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		Dist = vsize(HitLocation - Pawn.Location);
		if ( Dist > BestDist )
		{
			BestDist = Dist;
			Pick = DesiredRotation;
		}

		DesiredRotation.Yaw += 32768;
		Dir = vector(DesiredRotation);
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		Dist = vsize(HitLocation - Pawn.Location);
		if ( Dist > BestDist )
		{
			BestDist = Dist;
			Pick = DesiredRotation;
		}

		DesiredRotation = Pick;
	}

Begin:
    log("Sleeping:Begin"@Pawn.class);
	if ( IsSpawnCampProtecting() )	// spawn camp protection turrets should never sleep...
	{
		AcquisitionYawRate *= 100;
		Pawn.PeripheralVision = -1.0; // Full circle vision :)
		Awake();
	}
	ScanRotation();
	FocalPoint = Pawn.Location + 1000 * vector(DesiredRotation);
	//Sleep(2 + 3*FRand());
    log("ControllerSentryBase.Sleeping:Begin"@Pawn.class);

	Goto('Begin');
}

state Opening
{
	event SeePlayer(Pawn SeenPlayer){
    	log("AS-Opening:event SeePlayer: "@SeenPlayer.Class);
    }

	function AnimEnded()
	{
		GotoState('Searching');
	}
}

state Closing
{
	event SeePlayer(Pawn SeenPlayer){
    	log("AS-Closing:event SeePlayer: "@SeenPlayer.Class);
    }


	function AnimEnded()
	{
		GotoState('Sleeping');
	}

Begin:
	DesiredRotation			= Rotation;
	DesiredRotation.Pitch	= 0;
	FocalPoint = Pawn.Location + 1000 * vector(DesiredRotation);
	Sleep( 0.5 );
	Sentry(Pawn).GoToSleep();
}


state Searching
{
	function BeginState()
	{
		super.BeginState();
		StartSearchTime = Level.TimeSeconds;
	}

	function GoToSleep()
	{
		GotoState('Closing');
	}

Begin:
	if ( !IsSpawnCampProtecting() && (Level.TimeSeconds > StartSearchTime + 10) )
		GoToSleep();
	else
	{
		ScanRotation();
		FocalPoint = Pawn.Location + 1000 * vector(DesiredRotation);
		Sleep( GetScanDelay() );
		Goto('Begin');
	}
}

function bool IsSpawnCampProtecting()
{
	return ( Sentry(Pawn) != none && Sentry(Pawn).bSpawnCampProtection );
}

function float GetScanDelay()
{
//	if ( IsSpawnCampProtecting() )	// more aggressive scanning if spawn protecting
		return 2;

//	return ( 2 + 3*FRand() );
}

function float GetWaitForTargetTime()
{
//	if ( IsSpawnCampProtecting() )	// more aggressive scanning if spawn protecting
		return 2;

//	return super.GetWaitForTargetTime();
}

function Possess(Pawn aPawn)
{
	super.Possess( aPawn );

//	if ( IsSpawnCampProtecting() )	// kill on sight
//	{
		Skill = 10;
		FocusLead = 0;
//	}
}

defaultproperties
{
}
