//=============================================================================
// BerthaMortarShell.
//=============================================================================
class BerthaMortarShell extends ONSMortarShell;


var Emitter SmokeTrailEffect;
var bool bHitWater;
var Effects Corona;
var vector Dir;

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

    for (i=0; i<5; i++)
    {
        SmallShell = spawn(class'BerthaShellSmall', self, , Location, Rotation);
		if ( SmallShell != None )
			SmallShell.Velocity = Velocity + (VRand() * 500.0);
    }
    Destroy();
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer)
	{
        SmokeTrailEffect = Spawn(class'ONSTankFireTrailEffect',self);
		Corona = Spawn(class'RocketCorona',self);
	}

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}
    if ( Level.bDropDetail )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	Super.PostBeginPlay();
}

simulated function Destroyed()
{
	if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}


// Decompiled with UE Explorer.
defaultproperties
{
   // ExplosionEffectClass=class'UT2k4Assault.FX_SpaceFighter_Explosion'
   ExplosionEffectClass=class'XEffects.NewIonEffect'

    Damage=1300.0
    DamageRadius=2000.0
    MyDamageType=class'DamTypeArtilleryShellNEW'
    AmbientSound=none
    LifeSpan=999999.0
    TransientSoundVolume=1.0
    TransientSoundRadius=2048.0
}
