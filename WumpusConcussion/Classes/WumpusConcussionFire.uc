class WumpusConcussionFire extends InstantFire;

var name FireAnims[3];

//var()   class<Projectile>   ProjectileClass;


function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
    local Actor Other;
    local SniperWallHitEffect S;
    local Projectile P;


    Weapon.GetViewAxes(X, Y, Z);
    if ( Weapon.WeaponCentered() )
        ArcEnd = (Instigator.Location +
            Weapon.EffectOffset.X * X +
            1.5 * Weapon.EffectOffset.Z * Z);
    else
        ArcEnd = (Instigator.Location +
            Instigator.CalcDrawOffset(Weapon) +
            Weapon.EffectOffset.X * X +
            Weapon.Hand * Weapon.EffectOffset.Y * Y +
            Weapon.EffectOffset.Z * Z);

    X = Vector(Dir);
    End = Start + TraceRange * X;
    Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

//    if ( (Level.NetMode != NM_Standalone) || (PlayerController(Instigator.Controller) == None) )
//        Weapon.Spawn(class'TracerProjectile',Instigator.Controller,,Start,Dir);

/*************** here ********/
    P = Spawn(ProjectileClass,,,HitLocation,Rot(0,16384,0));
//    P = spawn(ProjectileClass, self, , StartLocation, WeaponFireRotation);

    P.HitWall(HitLocation, Other);

/*************** here ********/


    if ( Other != None && (Other != Instigator) )
    {
        if ( !Other.bWorldGeometry )
        {
            Other.TakeDamage(DamageMax, Instigator, HitLocation, Momentum*X, DamageType);
        }
        else
                HitLocation = HitLocation + 2.0 * HitNormal;
    }
    else
    {
        HitLocation = End;
        HitNormal = Normal(Start - End);
    }

    if ( (HitNormal != Vect(0,0,0)) && (HitScanBlockingVolume(Other) == None) )
    {
        S = Weapon.Spawn(class'SniperWallHitEffect',,, HitLocation, rotator(-1 * HitNormal));
        if ( S != None )
            S.FireStart = Start;
    }
}

function PlayFiring()
{
    Weapon.PlayAnim(FireAnims[Rand(3)], FireAnimRate, TweenTime);
    Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,,Default.FireAnimRate/FireAnimRate,false);
    ClientPlayForceFeedback(FireForce);
    FireCount++;
}

defaultproperties
{
     FireAnims(0)="Fire1"
     FireAnims(1)="Fire2"
     FireAnims(2)="fire3"
     DamageType=Class'WumpusConcussion.DamTypeWumpusConcussionShot'
     TraceRange=30000.000000
     FireSound=Sound'WeaponSounds.Misc.ballgun_launch'
     FireForce="NewSniperShot"
     FireRate=6.330000
     AmmoClass=Class'WumpusConcussion.WumpusConcussionAmmo'
     AmmoPerFire=1
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-15.000000,Z=10.000000)
     ShakeOffsetRate=(X=-4000.000000,Z=4000.000000)
     ShakeOffsetTime=1.600000
     ProjectileClass=Class'WumpusConcussion.ConcussionProjectile'
     BotRefireRate=6.400000
     WarnTargetPct=0.500000
     FlashEmitterClass=Class'XEffects.AssaultMuzFlash1st'
     aimerror=850.000000
}
