//=============================================================================
// flakshell
//=============================================================================
class BBRedeemerBomblet extends Projectile;

var	xemitter trail;
var vector initialDir;
var actor Glow;

var byte Bounces;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        Bounces;
}

simulated function PostBeginPlay()
{
//	local Rotator R;
	local PlayerController PC;
    local float rnd;

	if ( !PhysicsVolume.bWaterVolume && (Level.NetMode != NM_DedicatedServer) )
	{
		PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
			Trail = Spawn(class'FlakShellTrail',self);
		Glow = Spawn(class'FlakGlow', self);
	}

	Super.PostBeginPlay();
	/*
	Velocity = Vector(Rotation) * Speed;
	R = Rotation;
	R.Roll = 32768;
	SetRotation(R);
	Velocity.z += TossZ;
	initialDir = Velocity;
    */
    rnd = FRand();
    if (rnd > 0.75)
        Bounces = 3;
    else if (rnd > 0.25)
        Bounces = 2;
    else
        Bounces = 1;
}

simulated function destroyed()
{
	if ( Trail != None )
		Trail.mRegen=False;
	if ( glow != None )
		Glow.Destroy();
	Super.Destroyed();
}


simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( Other != Instigator )
	{
		SpawnEffects(HitLocation, -1 * Normal(Velocity) );
		Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}

simulated function SpawnEffects( vector HitLocation, vector HitNormal )
{
	local PlayerController PC;

	PlaySound (Sound'WeaponSounds.BExplosion1',,3*TransientSoundVolume);
	if ( EffectIsRelevant(Location,false) )
	{
		PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 3000 )
			spawn(class'FlakExplosion',,,HitLocation + HitNormal*16 );
		spawn(class'FlashExplosion',,,HitLocation + HitNormal*16 );
		spawn(class'RocketSmokeRing',,,HitLocation + HitNormal*16, rotator(HitNormal) );
		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
}

simulated function Landed( vector HitNormal )
{
	//SpawnEffects( Location, HitNormal );
	Log("Landed");
	//Explode(Location,HitNormal);
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	if (Bounces > 0)
    {
        Velocity = 0.65 * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
        Bounces = Bounces - 1;

        Explode(HitNormal,HitNormal);
        return;
    }
	Landed(HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;
    local rotator rot;
    local int i;
    local BBRedeemerGrenade NewChunk;
    local int magnitude;
    local vector mDirection;

	start = Location + 10 * HitNormal;
	//start = Location;
	if ( Role == ROLE_Authority )
	{
		HurtRadius(damage, 220, MyDamageType, MomentumTransfer, HitLocation);
		for (i=0; i<10; i++)
		{
            magnitude=600;
			//rot = Rotation;
			rot.yaw = (FRand()*magnitude*2)-magnitude;
			rot.pitch = (FRand()*magnitude*2)-magnitude;
			rot.roll = (FRand()*magnitude*2)-magnitude;

			NewChunk = Spawn( class 'BBRedeemerGrenade',, '', Start,rot);

            if(NewChunk != none){
                mDirection.X = (FRand()*magnitude*2)-magnitude;
                mDirection.Y = (FRand()*magnitude*2)-magnitude;
                mDirection.Z = (FRand()*magnitude*2)-magnitude;
                NewChunk.Velocity= mDirection;
            }
		}
	}
    Destroy();
}

defaultproperties
{
     Speed=1200.000000
     TossZ=225.000000
     Damage=90.000000
     MomentumTransfer=75000.000000
     MyDamageType=Class'XWeapons.DamTypeFlakShell'
     ExplosionDecal=Class'XEffects.ShockAltDecal'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakShell'
     CullDistance=4000.000000
     Physics=PHYS_Falling
     AmbientSound=Sound'WeaponSounds.BaseProjectileSounds.BFlakCannonProjectile'
     LifeSpan=6.000000
     DrawScale=8.000000
     Skins(0)=Texture'XWeapons.Skins.NewFlakSkin'
     AmbientGlow=100
     SoundVolume=255
     SoundRadius=100.000000
     bProjTarget=True
     bBounce=True
     ForceType=FT_Constant
     ForceRadius=60.000000
     ForceScale=5.000000
}
