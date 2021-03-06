/*******************************************************************************
 * VortexShell generated by Eliot.UELib using UE Explorer.
 * Eliot.UELib ? 2009-2013 Eliot van Uytfanghe. All rights reserved.
 * http://eliotvu.com
 *
 * All rights belong to their respective owners.
 *******************************************************************************/
class VortexShell extends Projectile;

var(VortexSounds) array<Sound> ImpactSounds;

simulated function PostBeginPlay()
{
    RandSpin(100000.0);
    //return;
}

simulated function HitWall(Vector HitNormal, Actor Wall)
{
    Velocity -= (((Velocity Dot HitNormal) * HitNormal) * RandRange(1.70, 1.90));
    Velocity *= RandRange(0.50, 0.70);
    RandSpin(100000.0);
    // End:0x74
    if(VSize(Velocity) > float(80))
    {
        PlaySound(ImpactSounds[Rand(ImpactSounds.Length)], SLOT_Misc);
    }
    // End:0x89
    else
    {
        // End:0x89
        if(VSize(Velocity) < float(10))
        {
            SetPhysics(PHYS_None);
        }
    }
    //return;
}

singular simulated function Touch(Actor Other)
{
    local Actor HitActor;
    local Vector HitLocation, HitNormal, VelDir;
    local bool bBeyondOther;
    local float BackDist, DirZ;

    // End:0x0D
    if(Other == none)
    {
        return;
    }
    // End:0x16B
    if(Other.bProjTarget || Other.bBlockActors && Other.bBlockPlayers)
    {
        // End:0x60
        if(Velocity == vect(0.0, 0.0, 0.0))
        {
            return;
        }
        bBeyondOther = (Velocity Dot (Location - Other.Location)) > float(0);
        VelDir = Normal(Velocity);
        DirZ = Sqrt(Abs(VelDir.Z));
        BackDist = (Other.CollisionRadius * (float(1) - DirZ)) + (Other.CollisionHeight * DirZ);
        // End:0x10A
        if(bBeyondOther)
        {
            BackDist += VSize(Location - Other.Location);
        }
        // End:0x128
        else
        {
            BackDist -= VSize(Location - Other.Location);
        }
        HitActor = Trace(HitLocation, HitNormal, Location, Location - ((1.10 * BackDist) * VelDir), true);
        HitWall(HitNormal, HitActor);
    }
    //return;
}

defaultproperties
{
    ImpactSounds(0)=Sound'ChaosEsounds3.Vortex.vortexshellbounce1'
    ImpactSounds(1)=Sound'ChaosEsounds3.Vortex.vortexshellbounce2'
    ImpactSounds(2)=Sound'ChaosEsounds3.Vortex.vortexshellbounce3'
    Physics=2
    RemoteRole=0
    LifeSpan=30.0
    Mesh=SkeletalMesh'Chaos_Extras1.Chaos_VXspherehf'
    DrawScale=1.20
    AmbientGlow=80
    CollisionRadius=2.0
    CollisionHeight=2.0
    bBounce=true
    bFixedRotationDir=true
    DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
