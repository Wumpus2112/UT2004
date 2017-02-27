//=============================================================================
// FlakChunk.
//=============================================================================
class Projectile_30mm extends Projectile;

var xEmitter Trail;
var byte Bounces;
var float DamageAtten;
var float BounceChancePercent;
var sound ImpactSounds[6];
var sound FireSoundClass;

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

 //   log("ZeroG:"$Speed);
    Velocity = vector(Rotation) * Speed;


    if(bBounce){
        r = FRand();
        if (r < BounceChancePercent/2)
            Bounces = 2;
        else if (r > BounceChancePercent)
            Bounces = 1;
        else
            Bounces = 0;
    }

    SetRotation(RotRand());

    PlaySound(FireSoundClass, SLOT_Misc, 255, true, 512);

    Super.PostBeginPlay();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    local float lSpeed;

    if ( (FlakChunk(Other) == None) && ((Physics == PHYS_Falling) || (Other != Instigator)) )
    {
        lSpeed = VSize(Velocity);
        if ( lSpeed > 200 )
        {
            if ( Role == ROLE_Authority )
            {
                if ( Instigator == None || Instigator.Controller == None )
                    Other.SetDelayedDamageInstigatorController( InstigatorController );

                Other.TakeDamage( Max(5, Damage - DamageAtten*FMax(0,(default.LifeSpan - LifeSpan - 1))), Instigator, HitLocation,
                    (MomentumTransfer * Velocity/lSpeed), MyDamageType );
            }
        }
        Destroy();
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
        Destroy();
        return;
    }

    //SetPhysics(PHYS_Falling);
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
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{

}

defaultproperties
{
     ImpactSounds(0)=Sound'XEffects.Impact4Snd'
     ImpactSounds(1)=Sound'XEffects.Impact6Snd'
     ImpactSounds(2)=Sound'XEffects.Impact7Snd'
     ImpactSounds(3)=Sound'XEffects.Impact3'
     ImpactSounds(4)=Sound'XEffects.Impact1'
     ImpactSounds(5)=Sound'XEffects.Impact2'
     FireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     Speed=6000.000000
     MaxSpeed=9000.000000
     Damage=20.000000
     MyDamageType=Class'XWeapons.DamTypeFlakChunk'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakChunk'
     LifeSpan=4.000000
     DrawScale=5.000000
     AmbientGlow=100
     Style=STY_Alpha
}
