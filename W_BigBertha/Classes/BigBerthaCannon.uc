//=============================================================================
// BigBerthaCannon.
//=============================================================================
class BigBerthaCannon extends ONSArtilleryCannon;

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local vector StartLocation, HitLocation, HitNormal, Extent, TargetLoc;
    local ONSIncomingShellSound ShellSoundMarker;
    local Controller C;
	local bool bFailed;

    for ( C=Level.ControllerList; C!=None; C=C.nextController )
		if ( PlayerController(C)!=None )
			PlayerController(C).ClientPlaySound(sound'DistantBooms.DistantSPMA',true,1);

	if ( AIController(Instigator.Controller) != None )
	{
		if ( Instigator.Controller.Target == None )
		{
			if ( Instigator.Controller.Enemy != None )
				TargetLoc = Instigator.Controller.Enemy.Location;
			else
				TargetLoc = Instigator.Controller.FocalPoint;
		}
		else
			TargetLoc = Instigator.Controller.Target.Location;

		if ( !bAltFire && ((MortarCamera == None) || MortarCamera.bShotDown)
			&& ((VSize(TargetLoc - WeaponFireLocation) > 5000) || !Instigator.Controller.LineOfSightTo(Instigator.Controller.Target)) )
		{
			ProjClass = AltFireProjectileClass;
			bAltFire = true;
		}
	}
    if (bDoOffsetTrace)
    {
       	Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
        Extent.Z = ProjClass.default.CollisionHeight;
        if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
            StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
    }
    else
    	StartLocation = WeaponFireLocation;

    P = spawn(ProjClass, self, , StartLocation, WeaponFireRotation);

    if (P != None)
    {
 		if ( AIController(Instigator.Controller) == None )
		{
			P.Velocity = Vector(WeaponFireRotation) * P.Speed;
		}
		else
		{
			if ( P.IsA('BerthaMortarCamera') )
			{
				P.Velocity = SetMuzzleVelocity(StartLocation, TargetLoc,0.55);
				BerthaMortarCamera(P).TargetZ = TargetLoc.Z;
			}
			else
				P.Velocity = SetMuzzleVelocity(StartLocation, TargetLoc,0.85);
			WeaponFireRotation = Rotator(P.Velocity);
			BigBertha(Owner).bAltFocalPoint = true;
			BigBertha(Owner).AltFocalPoint = StartLocation + P.Velocity;
		}
		if ( !P.IsA('BerthaMortarCamera') )
        {
           if (MortarCamera != None)
            {
				if ( AIController(Instigator.Controller) == None )
				{
					MortarSpeed = FClamp(WeaponCharge * (MaxSpeed - MinSpeed) + MinSpeed, MinSpeed, MaxSpeed);
					BerthaMortarShell(P).Velocity = Normal(P.Velocity) * MortarSpeed;
				}
                ShellSoundMarker = spawn(class'ONSIncomingShellSound',,, PredictedTargetLocation + vect(0,0,400));
                ShellSoundMarker.StartTimer(PredicatedTimeToImpact);
            }
			else
				P.LifeSpan = 999999.0;
        }
         FlashMuzzleFlash();

        // Play firing noise
        if (bAltFire)
        {
            if (bAmbientAltFireSound)
                AmbientSound = AltFireSoundClass;
            else
                PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }
        else
        {
            if (bAmbientFireSound)
                AmbientSound = FireSoundClass;
            else
                PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }

        if (BerthaMortarCamera(P) != None)
        {
			CameraAttempts = 0;
			LastCameraLaunch = Level.TimeSeconds;
            MortarCamera = BerthaMortarCamera(P);
            if (BigBertha(Owner) != None)
                BigBertha(Owner).MortarCamera = MortarCamera;
        }
        else
            MortarShell = BerthaMortarShell(P);
    }
	else if ( AIController(Instigator.Controller) != None )
	{
		bFailed = BerthaMortarCamera(P) == None;
		if ( !bFailed )
		{
			// allow 2 tries
			CameraAttempts++;
			bFailed = ( CameraAttempts > 1 );
		}

		if ( bFailed )
		{
			CameraAttempts = 0;
			LastCameraLaunch = Level.TimeSeconds;
			if ( MortarCamera != None )
			{
				MortarCamera.Destroy();
			}
		}
	}
    return P;
}


// Decompiled with UE Explorer.
defaultproperties
{
     RedSkin=Texture'BerthaTextures.Skins.SPMARedBlack'
     BlueSkin=Texture'BerthaTextures.Skins.SPMABlueBlack'

    ProjectileClass=class'BerthaMortarShell'
    AltFireProjectileClass=class'BerthaMortarCamera'
}
