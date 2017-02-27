//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FlakProjectile extends Projectile;

#exec OBJ LOAD FILE=..\Sounds\VMVehicleSounds-S.uax

var Emitter SmokeTrailEffect;
var bool bHitWater;
var Effects Corona;
var vector Dir;

var float ExplodeTimer;
var float FuzeTimer;
var bool bTimerSet;

replication
{
    reliable if (Role==ROLE_Authority)
        ExplodeTimer;
}

simulated function Destroyed()
{
	if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
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

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
		Explode(HitLocation,Vect(0,0,1));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local vector start;
    local rotator rot;
    local int i;
    local FlakSubProjectile NewChunk;

    bTimerSet = false;
    Spawn(class'FX_SpaceFighter_Explosion', Self,, HitLocation, Rotation);
    HurtRadius(damage, ForceRadius*2, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);

    start = Location + 10 * HitNormal;
    if ( Role == ROLE_Authority )
    {
        HurtRadius(damage, 220, MyDamageType, MomentumTransfer, HitLocation);
        for (i=0; i<6; i++)
        {
            rot = Rotation;
            rot.yaw += FRand()*32000-16000;
            rot.pitch += FRand()*32000-16000;
            rot.roll += FRand()*32000-16000;
            NewChunk = Spawn( class 'FlakSubProjectile',, '', Start, rot);
        }
    }
    Destroy();
}

simulated function PostNetBeginPlay()
{
    FuzeTimer =( ExplodeTimer*FRand() )+0.15;
    bTimerSet = true;
}

simulated function Tick(float DeltaTime)
{
    FuzeTimer = FuzeTimer - DeltaTime;
    if(FuzeTimer < 0.0 && bTimerSet){
        Explode(Location, vect(0,0,1));
    }
}

defaultproperties
{
     Speed=15000.000000
     MaxSpeed=15000.000000
     Damage=150.000000
     DamageRadius=660.000000
     MomentumTransfer=125000.000000
     MyDamageType=Class'Onslaught.DamTypeTankShell'
     ExplosionDecal=Class'Onslaught.ONSRocketScorch'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RocketProj'
     AmbientSound=Sound'VMVehicleSounds-S.HoverTank.IncomingShell'
     LifeSpan=2.00000
     AmbientGlow=96
     FluidSurfaceShootStrengthMod=10.000000
     bFullVolume=True
     SoundVolume=255
     SoundRadius=1000.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=1000.000000
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant

    ForceScale=50.0
    ForceRadius=400.0
//    Physics=PHYS_Projectile
    //speed=8000.000000
    //LifeSpan=4.000000
    ExplodeTimer=0.50

}
