//=============================================================================
// ASTurret_BallTurret
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FlackTurret extends ONSWeaponPawn;

defaultproperties
{
     YawBone="TankTurret"
     PitchBone="TankBarrel"
     PitchUpLimit=6000
     PitchDownLimit=61500
     WeaponFireAttachmentBone="TankBarrel"
     WeaponFireOffset=200.000000
     RotationsPerSecond=0.180000
     Spread=0.015000
     RedSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalRED'
     BlueSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalBLUE'
     FireInterval=2.500000
     EffectEmitterClass=Class'Onslaught.ONSTankFireEffect'
     FireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     FireSoundVolume=512.000000
     FireForce="Explosion05"
//     ProjectileClass=Class'Onslaught.ONSRocketProjectile'

     ProjectileClass=Class'W_FlackPanzer.FlackTurretProjectile'

     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.800000)
//     Mesh=SkeletalMesh'ONSWeapons-A.HoverTankCannon'


//    DefaultWeaponClassName="Battlestar.FlackTurretWeapon"
//    TurretBaseClass=class'Battlestar.FlackTurretBase'

    WeaponInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid_Skaarj'

    DrawType=DT_Mesh
    Mesh=SkeletalMesh'AS_VehiclesFull_M.ASTurret_MotherShip2'


}




defaultproperties
{
//    bHideRemoteDriver=true
//    bRelativeExitPos=false
//    bHasRadar=true
}
