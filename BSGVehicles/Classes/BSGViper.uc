//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BSGViper extends BSGFighter;

simulated function ClientKDriverEnter(PlayerController PC)
{
    super.ClientKDriverEnter( PC );

    // Don't start at full speed
    Velocity = EngineMinVelocity * Vector(Rotation);
    Acceleration = Velocity;
}

function float ImpactDamageModifier()
{
    return ImpactDamageMult;
}

DefaultProperties
{
    mesh=SkeletalMesh'VI.VI'
    Skins[0]=texture'BSGVehicles.BSGVehicles.Viper'

    MinFlySpeed=0.0
    EngineMinVelocity=0.0

    bCollideActors=True
    bBlockActors=True
}
