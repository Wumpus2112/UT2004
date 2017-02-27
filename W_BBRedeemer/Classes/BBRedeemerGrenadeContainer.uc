//=============================================================================
// FlakChunk.     DO NOT USE
//=============================================================================
class BBRedeemerGrenadeContainer extends Projectile;

var xEmitter Trail;
var byte Bounces;
var float DamageAtten;
var sound ImpactSounds[6];

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        Bounces;
}

simulated function Destroyed()
{
    if (Trail !=None) Trail.mRegen=False;
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
    local float r;

    if ( Level.NetMode != NM_DedicatedServer )
    {
        if ( !PhysicsVolume.bWaterVolume )
        {
            Trail = Spawn(class'FlakTrail',self);
            Trail.Lifespan = Lifespan;
        }

    }

    Velocity = Vector(Rotation) * (Speed);
    if (PhysicsVolume.bWaterVolume)
        Velocity *= 0.65;

    r = FRand();
    if (r > 0.75)
        Bounces = 3;
    else if (r > 0.25)
        Bounces = 2;
    else
        Bounces = 1;

    SetRotation(RotRand());

    //Log("Create BBRedeemerGrenadeContainer");

    Super.PostBeginPlay();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    if ( (FlakChunk(Other) == None) && ((Physics == PHYS_Falling) || (Other != Instigator)) )
    {
        speed = VSize(Velocity);
        if ( speed > 200 )
        {
            if ( Role == ROLE_Authority )
			{
				if ( Instigator == None || Instigator.Controller == None )
					Other.SetDelayedDamageInstigatorController( InstigatorController );

                Other.TakeDamage( Max(5, Damage - DamageAtten*FMax(0,(default.LifeSpan - LifeSpan - 1))), Instigator, HitLocation,
                    (MomentumTransfer * Velocity/speed), MyDamageType );
			}
        }
        SpawnGrenadeContainers(HitLocation, HitLocation);
        Destroy();
    }
}

simulated function SpawnGrenadeContainers(vector HitLocation, vector HitNormal)
{
	local vector start;
    local rotator rot;
    local int i;
    local BBRedeemerGrenade NewChunk;

	//start = Location + 10 * HitNormal;
	start = HitLocation;

	if ( Role == ROLE_Authority )
	{
		HurtRadius(damage, 220, MyDamageType, MomentumTransfer, HitLocation);
		for (i=0; i<10; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*12800-6400;
			rot.pitch += FRand()*12800-6400;
			rot.roll += FRand()*12800-6400;


			NewChunk = Spawn( class 'BBRedeemerGrenade',, '', Start, rot);
		}
	}
}

simulated function Landed( Vector HitNormal )
{
    SetPhysics(PHYS_None);
    LifeSpan = 1.0;
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    if ( !Wall.bStatic && !Wall.bWorldGeometry
		&& ((Mover(Wall) == None) || Mover(Wall).bDamageTriggered) )
    {
        if ( Level.NetMode != NM_Client )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Wall.SetDelayedDamageInstigatorController( InstigatorController );
            Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
		}
		SpawnGrenadeContainers(HitNormal, HitNormal);
        Destroy();
        return;
    }

    SetPhysics(PHYS_Falling);
	if (Bounces > 0)
    {
		if ( !Level.bDropDetail && (FRand() < 0.4) )
			Playsound(ImpactSounds[Rand(6)]);

        Velocity = 0.65 * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
        Bounces = Bounces - 1;
        return;
    }
	bBounce = false;
    if (Trail != None)
    {
        Trail.mRegen=False;
        Trail.SetPhysics(PHYS_None);
        //Trail.mRegenRange[0] = 0.0;//trail.mRegenRange[0] * 0.6;
        //Trail.mRegenRange[1] = 0.0;//trail.mRegenRange[1] * 0.6;
    }
    SpawnGrenadeContainers(HitNormal, HitNormal);
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
    if (Volume.bWaterVolume)
    {
        if ( Trail != None )
            Trail.mRegen=False;
        Velocity *= 0.65;
    }
}

defaultproperties
{
     Bounces=1
     DamageAtten=5.000000
     ImpactSounds(0)=Sound'XEffects.Impact4Snd'
     ImpactSounds(1)=Sound'XEffects.Impact6Snd'
     ImpactSounds(2)=Sound'XEffects.Impact7Snd'
     ImpactSounds(3)=Sound'XEffects.Impact3'
     ImpactSounds(4)=Sound'XEffects.Impact1'
     ImpactSounds(5)=Sound'XEffects.Impact2'
     Speed=2500.000000
     MaxSpeed=2700.000000
     Damage=13.000000
     MomentumTransfer=10000.000000
     MyDamageType=Class'XWeapons.DamTypeFlakChunk'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakChunk'
     CullDistance=3000.000000
     Physics=PHYS_Falling
     LifeSpan=12.700000
     DrawScale=14.000000
     AmbientGlow=254
     Style=STY_Alpha
     bBounce=True
}
