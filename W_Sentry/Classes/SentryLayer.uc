class SentryLayer extends Weapon
    config(user);

function PrebeginPlay()
{
	Super.PreBeginPlay();
}

simulated function SuperMaxOutAmmo()
{}

simulated event ClientStopFire(int Mode)
{
    if (Role < ROLE_Authority)
    {
        StopFire(Mode);
    }
    if ( Mode == 0 )
		ServerStopFire(Mode);
}

simulated event WeaponTick(float dt)
{
	if ( (Instigator.Controller == None) || HasAmmo() )
		return;
	Instigator.Controller.SwitchToBestWeapon();
}


// AI Interface
function float SuggestAttackStyle()
{
    return -1.0;
}

function float SuggestDefenseStyle()
{
    return -1.0;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	return 0;
}

function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return 0.4;

	if ( B.IsShootingObjective() )
		return 1.0;

	if ( (B.Enemy == None) || B.Enemy.bCanFly || VSize(B.Enemy.Location - Instigator.Location) < 2400 )
		return 0.4;

	return AIRating;
}

defaultproperties
{
     FireModeClass(0)=Class'W_Sentry.SentryThrowFire'
     FireModeClass(1)=Class'W_Sentry.SentryThrowFire'
     PutDownAnim="PutDown"
     SelectAnimRate=2.000000
     PutDownAnimRate=4.000000
     PutDownTime=0.400000
     BringUpTime=0.350000
     SelectSound=Sound'WeaponSounds.FlakCannon.SwitchToFlakCannon'
     SelectForce="SwitchToFlakCannon"
     AIRating=0.550000
     CurrentRating=0.550000
     Description="Builds Sentrys that automatically targets enemies."
     EffectOffset=(X=100.000000,Y=32.000000,Z=-20.000000)
     DisplayFOV=45.000000
     Priority=5
     HudColor=(B=255,G=0,R=0)
     SmallViewOffset=(X=116.000000,Y=43.500000,Z=-40.500000)
     CustomCrosshair=14
     CustomCrossHairTextureName="ONSInterface-TX.MineLayerReticle"
     InventoryGroup=0
     GroupOffset=1
     PickupClass=Class'W_Sentry.SentryPickup'
     PlayerViewOffset=(X=100.000000,Y=35.500000,Z=-32.500000)
     BobDamping=2.200000
     AttachmentClass=Class'W_Sentry.SentryLayerAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=229,Y1=258,X2=296,Y2=307)
     ItemName="Sentry - Builder"
     Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretBase'
     AmbientGlow=64
}
