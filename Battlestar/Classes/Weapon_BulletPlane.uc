//=============================================================================
// FlakChunk.
//=============================================================================
class Weapon_BulletPlane extends Projectile;

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
    local SpaceFighterBase sfb;

    if ( Level.NetMode != NM_DedicatedServer )
    {
        if ( !PhysicsVolume.bWaterVolume )
        {
            Trail = Spawn(class'FlakTrail',self);
            Trail.Lifespan = Lifespan;
        }

    }

    sfb = SpaceFighterBase(Instigator);

    Velocity = vector(Rotation) * Speed;
    Velocity = Velocity + Instigator.Velocity;

    r = FRand();
    if (r > 0.75)
        Bounces = 2;
    else if (r > 0.25)
        Bounces = 1;
    else
        Bounces = 0;

    SetRotation(RotRand());

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
    Style=STY_Alpha
    //Style=STY_Additive

    ScaleGlow=1.0
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'WeaponStaticMesh.FlakChunk'
    MyDamageType=class'DamTypeFlakChunk'
    AmbientGlow=100
    DrawScale=5.0

    FluidSurfaceShootStrengthMod=1.f
//    speed=2500.000000
//    MaxSpeed=2700.000000
    Speed=4000.000000
    MaxSpeed=9000.000000

    Damage=30
    DamageAtten=0.0 // damage reduced per second from when the chunk was fired
    MomentumTransfer=0
    LifeSpan=4.0
    bBounce=true
    Bounces=1
    NetPriority=2.500000

//    CullDistance=+3000.0
    ImpactSounds(0)=sound'XEffects.Impact4Snd'
    ImpactSounds(1)=sound'XEffects.Impact6Snd'
    ImpactSounds(2)=sound'XEffects.Impact7Snd'
    ImpactSounds(3)=sound'XEffects.Impact3'
    ImpactSounds(4)=sound'XEffects.Impact1'
    ImpactSounds(5)=sound'XEffects.Impact2'


     //AccelerationMagnitude=16000

 /*
    Lifespan=1.6
    Speed=7000
    MaxSpeed=7000
    AccelerationMagnitude=0.0
    Damage=70
    DamageRadius=240.0
    MomentumTransfer=4000
    Physics=PHYS_Projectile
    DrawType=DT_None
    Style=STY_Additive
    AmbientGlow=100

    HitEffectClass=class'Onslaught.ONSPlasmaHitPurple'
*/
}