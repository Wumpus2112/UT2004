//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BSGBlackbird extends BSGFighter;

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
//    mesh=SkeletalMesh'VI.VI'
    Mesh=SkeletalMesh'ONSVehicles-A.AttackCraft'
//    Skins[0]=texture'BSGVehicles.BSGVehicles.Viper'
//     RedSkin=Shader'VMVehicles-TX.AttackCraftGroup.AttackCraftChassisFinalRED'
//     BlueSkin=Shader'VMVehicles-TX.AttackCraftGroup.AttackCraftChassisFInalBLUE'

Skins[0]=Shader'VMVehicles-TX.AttackCraftGroup.AttackCraftChassisFinalRED'

    MinFlySpeed=0.0
    EngineMinVelocity=0.0

    bCollideActors=True
    bBlockActors=True
}
