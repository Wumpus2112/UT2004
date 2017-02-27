/******************************************************************************
HoverTankWeaponPawn

Creation date: 2013-02-16 13:02
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class FlakPanzerWeapon extends ONSWeapon;
/*
defaultproperties
{
    DefaultWeaponClassName="Battlestar.FlackTurretWeapon"
    TurretBaseClass=class'Battlestar.FlackTurretBase'

    WeaponInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid_Skaarj'

    DrawType=DT_Mesh
    Mesh=SkeletalMesh'AS_VehiclesFull_M.ASTurret_MotherShip2'
    bHideRemoteDriver=true
    bRelativeExitPos=false
    bHasRadar=true
}
*/
defaultproperties
{
//     YawBone="TankTurret"
//     PitchBone="TankBarrel"
     YawBone="TurretYaw"
     PitchBone="TurretPitch"
     PitchUpLimit=15000
     PitchDownLimit=61500
//     WeaponFireAttachmentBone="TankBarrel"
     WeaponFireAttachmentBone="Firepoint"

     WeaponFireOffset=200.000000
     RotationsPerSecond=0.180000
     Spread=0.015000
     //RedSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalRED'
     //BlueSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalBLUE'
     FireInterval=0.8000
     EffectEmitterClass=Class'Onslaught.ONSTankFireEffect'
     FireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     FireSoundVolume=512.000000
     FireForce="Explosion05"
//     ProjectileClass=Class'Onslaught.ONSRocketProjectile'
     ProjectileClass=Class'FlakProjectile'

     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.800000)
//     Mesh=SkeletalMesh'ONSWeapons-A.HoverTankCannon'
//     Mesh=SkeletalMesh'AS_VehiclesFull_M.ASTurret_MotherShip2'

     Mesh=Mesh'FlakPanzer_Anim.BSFlakTurret'


     RedSkin=Texture'November2ship.textures.turretskin'
     BlueSkin=Texture'November2ship.textures.turretskin'

     DrawScale=0.8000
}
