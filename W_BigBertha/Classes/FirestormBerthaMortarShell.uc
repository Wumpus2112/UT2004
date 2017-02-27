//=============================================================================
// BerthaMortarShell.
//=============================================================================
class FirestormBerthaMortarShell extends ONSMortarShell;

simulated function SpawnEffects( vector HitLocation, vector HitNormal )
{
	local PlayerController PC;

	//PlaySound(SoundGroup'BWNewSounds.SPMA.Fragz',,1.1*TransientSoundVolume);
	PlaySound(sound'ONSBPSounds.Artillery.ShellFragmentExplode', SLOT_None, 2.0);
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

simulated function Timer()
{
    local int i;
    local BerthaShellSmall SmallShell;


	PlaySound(sound'ONSBPSounds.Artillery.ShellBrakingExplode');
	if ( Level.NetMode != NM_DedicatedServer )
		spawn(class'ONSArtilleryShellSplit', self, , Location, Rotation);

    for (i=0; i<15; i++)
    {
        SmallShell = spawn(class'BerthaShellSmall', self, , Location, Rotation);
		if ( SmallShell != None )
			SmallShell.Velocity = Velocity + (VRand() * 500.0);
    }
    Destroy();
}


// Decompiled with UE Explorer.
defaultproperties
{
    ExplosionEffectClass=class'UT2k4Assault.FX_SpaceFighter_Explosion'
    Damage=650.0
    DamageRadius=2000.0
    MyDamageType=class'DamTypeHomeArtilleryShellNEW'
    TransientSoundVolume=1.0
    TransientSoundRadius=2048.0
}
