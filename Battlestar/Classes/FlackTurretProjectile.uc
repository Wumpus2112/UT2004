//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FlackTurretProjectile extends FlakShell;

var float ExplodeTimer;
var bool bTimerSet;

replication
{
    reliable if (Role==ROLE_Authority)
        ExplodeTimer;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local vector start;
    local rotator rot;
    local int i;
    local FlackTurretSubProjectile NewChunk;

//    Spawn(class'NewExplosionB',,, HitLocation, rotator(vect(0,0,1)));
//    ExplosionEffect = Spawn(class'FX_SpaceFighter_Explosion', Self,, HitLocation, Rotation);
    Spawn(class'FX_SpaceFighter_Explosion', Self,, HitLocation, Rotation);
    HurtRadius(damage, ForceRadius*2, MyDamageType, MomentumTransfer, HitLocation );

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
            NewChunk = Spawn( class 'FlackTurretSubProjectile',, '', Start, rot);
        }
    }
    Destroy();
}


simulated function PostNetBeginPlay()
{
    SetTimer(((ExplodeTimer-0.5)*FRand())+0.5, false);
    bTimerSet = true;
}

simulated function Timer()
{
    Explode(Location, vect(0,0,1));
}

DefaultProperties
{
/*
    ExplosionDecal=class'ShockAltDecal'
    TossZ=+225.0
    bProjTarget=True
    speed=1200.000000
    Damage=90.000000
    MomentumTransfer=75000
    bNetTemporary=True
    Physics=PHYS_Falling
    MyDamageType=class'DamTypeFlakShell'
    LifeSpan=6.000000
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'WeaponStaticMesh.FlakShell'
    Skins(0)=texture'NewFlakSkin'
    DrawScale=8.0
    AmbientGlow=100
    AmbientSound=Sound'WeaponSounds.BaseProjectileSounds.BFlakCannonProjectile'
    SoundRadius=100
    SoundVolume=255
    ForceType=FT_Constant
    ForceScale=5.0
    ForceRadius=60.0
    CullDistance=+4000.0
*/
    Damage=150.000000
    SoundRadius=400
    SoundVolume=255
    ForceScale=50.0
    ForceRadius=400.0
    Physics=PHYS_Projectile
    speed=8000.000000
    LifeSpan=4.000000
    ExplodeTimer=2.0
}