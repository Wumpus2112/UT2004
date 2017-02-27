//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WeaponDragonGunPawn extends ONSWeaponPawn;



function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoom();
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}


function ShouldTargetMissile(Projectile P)
{
	if ( Bot(Controller) != None && Bot(Controller).Skill >= 5.0 )
	{
		if ( (Controller.Enemy != None) && Bot(Controller).EnemyVisible() && (Bot(Controller).Skill < 5) )
			return;
		ShootMissile(P);
	}
}

defaultproperties
{
     GunClass=Class'W_Dragon.WeaponDragonGun'
     CameraBone="GatlingGunAttach"
     bDrawDriverInTP=False
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryPosition=(Z=-150.000000)
     EntryRadius=130.000000
     FPCamPos=(X=35.000000,Z=15.000000)
     TPCamDistance=0.000000
     TPCamLookat=(X=5.000000,Z=-50.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Dragon turret"
     VehicleNameString="Dragon Gun Turret"
}
