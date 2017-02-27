//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SentryFire extends FM_Sentinel_Fire;

function Rotator AdjustAim(Vector Start, float InAimError)
{
    log("FortressSentryFire.AdjustAim");
    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = AmmoClass;
        SavedFireProperties.ProjectileClass = ProjectileClass;
        SavedFireProperties.WarnTargetPct = WarnTargetPct;
        SavedFireProperties.MaxRange = MaxRange();
        SavedFireProperties.bTossed = bTossed;
        SavedFireProperties.bTrySplash = bRecommendSplashDamage;
        SavedFireProperties.bLeadTarget = bLeadTarget;
        SavedFireProperties.bInstantHit = bInstantHit;
        SavedFireProperties.bInitialized = true;
    }
    return Instigator.AdjustAim(SavedFireProperties, Start, InAimError);
}

defaultproperties
{
     TeamProjectileClasses(0)=Class'W_Sentry.PROJ_Sentry_Laser_Red'
     TeamProjectileClasses(1)=Class'W_Sentry.PROJ_Sentry_Laser'
}
