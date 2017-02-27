class Weapon_BulletFireZeroG extends ProjectileFire;

var bool                bSwitch;

event ModeDoFire()
{
    if ( Weapon.ThirdPersonActor != None )
        bSwitch = ( (WeaponAttachment(Weapon.ThirdPersonActor).FlashCount % 2) == 1 );
    else
        bSwitch = !bSwitch;

    super.ModeDoFire();
}

function DoFireEffect()
{
    local Vector    Start, X,Y,Z, HL, HN;

    //if ( Instigator.IsA('ASVehicle') )
    //    ProjOffset = ASVehicle(Instigator).VehicleProjSpawnOffset;

    //ProjSpawnOffset = ProjOffset;
    if ( bSwitch )
        ProjSpawnOffset.Y = -ProjSpawnOffset.Y;

    //Instigator.MakeNoise(1.0);
    Instigator.GetAxes(Instigator.Rotation, X, Y, Z);

    Start = MyGetFireStart(X, Y, Z);

    ASVehicle(Instigator).CalcWeaponFire( HL, HN );
    SpawnProjectile(Start, rotator(HL - Start));
}

simulated function vector MyGetFireStart(vector X, vector Y, vector Z)
{
    return Instigator.Location + X*ProjSpawnOffset.X + Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
}


function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    p = Weapon.Spawn(ProjectileClass, Instigator, , Start, Dir);
    if ( p == None )
        return None;

    p.Damage *= DamageAtten;
    return p;
}

function InitEffects()
{
    Super.InitEffects();
//    if ( FlashEmitter != None )
//        Weapon.AttachToBone(FlashEmitter, 'tip');
}


defaultproperties
{
    AmmoClass=class'Ammo_Dummy'
    AmmoPerFire=0

    FireAnim=Fire
    FireAnimRate=1.0
    FireLoopAnim=None
    FireEndAnim=None

    //ProjectileClass=class'XWeapons.FlakChunk'
    ProjectileClass=class'Weapon_BulletZeroG';
    ProjPerFire=1

    ProjSpawnOffset=(X=25,Y=50,Z=-14)

//    ProjSpawnOffset=(X=25,Y=5,Z=-6)

//    SpreadStyle=SS_Random
//    Spread=1400

    FlashEmitterClass=class'XEffects.FlakMuzFlash1st'

    //FireSound=sound'WeaponSounds.FlakCannon.FlakCannonFire'
    //FireSound=sound'WeaponSounds.ballgun_launch'
    //FireSound=sound'WeaponSounds.MiniGun.MiniAltFireb'
    //FireSound=sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact1'
    //FireSound=sound'WeaponSounds.BaseFiringSounds.BSniperRifleAltFile'
    FireSound=sound'WeaponSounds.SniperRifle.SniperRifleAltFire'

    FireForce="FlakCannonFire"  // jdf

    FireRate=0.05
    BotRefireRate=0.05

//    FireSound=Sound'WeaponSounds.PulseRifle.PulseRifleFire'
//    LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
//    FireForce="TranslocatorFire"  // jdf
//    LinkedFireForce="BLinkedFire"  // jdf

    bSplashDamage=false
    bRecommendSplashDamage=false
    WarnTargetPct=+0.1

    ShakeOffsetMag=(X=0.0,Y=1.0,Z=0.0)
    ShakeOffsetRate=(X=0.0,Y=-2000.0,Z=0.0)
    ShakeOffsetTime=4
    ShakeRotMag=(X=40.0,Y=0.0,Z=0.0)
    ShakeRotRate=(X=2000.0,Y=0.0,Z=0.0)
    ShakeRotTime=2
}