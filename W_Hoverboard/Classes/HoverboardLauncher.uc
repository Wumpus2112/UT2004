//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HoverboardLauncher extends Weapon;

defaultproperties
{
    FireModeClass(0)=Class'HoverboardLauncherFire'

    FireModeClass(1)=Class'HoverboardLauncherFire'

    PutDownAnim=PutDown

    PutDownAnimRate=2.50

    PutDownTime=0.20

    SelectSound=Sound'WeaponSounds.Misc.ballgun_change'

    SelectForce="ballgun_change"

    AIRating=0.10

    CurrentRating=0.10

    bCanThrow=False

    EffectOffset=(X=30.00,Y=10.00,Z=-10.00),

    DisplayFOV=60.00

    Priority=17

    SmallViewOffset=(X=23.00,Y=6.00,Z=-6.00),

    CenteredOffsetY=-5.00

    CenteredRoll=5000

    CenteredYaw=-300

    CustomCrosshair=11

    CustomCrossHairColor=(R=0,G=255,B=255,A=255),

    CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Bracket2"

    MinReloadPct=0.00

    InventoryGroup=10

    GroupOffset=2

    PlayerViewOffset=(X=11.00,Y=0.00,Z=0.00),

    BobDamping=2.20

    AttachmentClass=Class'XWeapons.BallAttachment'

    ItemName="Hoverboard Launcher"

    Mesh=SkeletalMesh'Weapons.BallLauncher_1st'

    DrawScale=0.40

}