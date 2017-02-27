class DamTypeHomeArtilleryShellNEW extends VehicleDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
    HitEffects[0] = class'HitSmoke';

    if( VictimHealth <= 0 )
        HitEffects[1] = class'HitFlameBig';
    else if ( FRand() < 0.8 )
        HitEffects[1] = class'HitFlame';
}


// Decompiled with UE Explorer.
defaultproperties
{
    VehicleClass=class'HellfireBigBertha'
    DeathString="%k gave %o an explosive shell for breakfast."
    FemaleSuicide="%o was killed by an explosive strike."
    MaleSuicide="%o was killed by an explosive strike."
    bDetonatesGoop=true
    bDelayedDamage=true
    bThrowRagdoll=true
    bFlaming=true
    GibPerterbation=0.150
}