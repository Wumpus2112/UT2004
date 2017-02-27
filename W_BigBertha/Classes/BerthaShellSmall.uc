//=============================================================================
// BerthaShellSmall.
//=============================================================================
class BerthaShellSmall extends FirestormBerthaMortarShell;


simulated function SpawnEffects( vector HitLocation, vector HitNormal )
{
	local PlayerController PC;

PlaySound(sound'ONSBPSounds.Artillery.ShellFragmentExplode', SLOT_None, 2.0);
//	PlaySound(SoundGroup'BWNewSounds.SPMA.Explode',,1.0*TransientSoundVolume);
	if ( EffectIsRelevant(Location,false) )
	{
		PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 3000 )
			spawn(ExplosionEffectClass,,,HitLocation + HitNormal*16 );
		spawn(ExplosionEffectClass,,,HitLocation + HitNormal*16 );
		spawn(class'RocketSmokeRing',,,HitLocation + HitNormal*16, rotator(HitNormal) );
		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
}


// Decompiled with UE Explorer.
defaultproperties
{
//    ExplosionEffectClass=class'OnslaughtBP.ONSArtilleryShellSplit'
    ExplosionEffectClass=class'UT2k4Assault.FX_SpaceFighter_Explosion'
    Damage=150.0
    DamageRadius=500.0
    MyDamageType=class'DamTypeSmallArtilleryShellNEW'
    //StaticMesh=StaticMesh'ONS-BPJW1.Meshes.Mini_Shell'
    bNetTemporary=true
    DrawScale=5.0
    TransientSoundVolume=1.80
    TransientSoundRadius=1024.0
}
