//=============================================================================
// The IonCannon
//=============================================================================
class DarkMatterCannon extends Actor
    placeable;

var() sound AntiGravSound;
var() Sound FireSound;
var() Vector MarkLocation;
var() class<DarkIonEffect> IonEffectClass;
var() int Damage; // per wave
var() float MomentumTransfer; // per wave
var() float DamageRadius; // of final wave
var() class<DamageType> DamageType;
var Vector BeamDirection;
var Vector DamageLocation;
var AvoidMarker Fear;

// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view

/******/
var() float QuantumGravity;
var() float QuantumRange;
var() float InitialDelay;
var() float BuildUpTime;
var() float EffectsSpawnTime;
var() float ActiveTime;
var() float CalmDownTime;
var() float DampenFactor;
var() float DampenFactorParallel;
var() float KickUpSpeed;
var() float KillRadius;
//var(QuantumSounds) Sound QuantumStartSound;
//var(QuantumSounds) array<Sound> QuantumFlash;
//var(QuantumSounds) Sound QuantumAmbientSound;
//var(QuantumSounds) array<Sound> SlurpSound;
//var(QuantumSounds) array<Sound> ImpactSounds;
var float StartTimeIndex;
var float StrengthFadeTimeIndex;
var float DamageTime;
var Emitter QuantumEmitter;
var Emitter QuantumMainLightning;
var Emitter QuantumLightning;
var float EndTime;

replication
{
    reliable if((Role == ROLE_Authority) && bNetInitial)
        EndTime, InitialDelay;
}
/******/





function PostBeginPlay()
{
	local IonCannon C;

    Super.PostBeginPlay();
    if ( bDeleteMe )
		return;

	ForEach DynamicActors(Class'IonCannon',C)
	{
		if ( C != self )
			C.Destroy();
	}
}

function bool CheckMarkDM(Pawn Aimer, Vector TestMark, bool bFire)
{
    return false;
}

auto state Ready
{
    function bool CheckMarkDM(Pawn Aimer, Vector TestMark, bool bFire)
    {
        local Actor Other;
        local Vector HitLocation, HitNormal,Top;

        if (IsFiring())
            return false;

		Top = TestMark;
		Top.Z = Location.Z;
        Other = Trace(HitLocation, HitNormal, Top, TestMark, false);

        if ( Other != None )
            return false;

        if (bFire)
        {
            Instigator = Aimer;
            MarkLocation = TestMark;
            GotoState('FireSequence');
        }

        return true;
    }
}

function RemoveFear()
{
	if ( Fear != None )
		Fear.Destroy();
}

state FireSequence
{
	function RemoveFear();

	function bool IsFiring()
	{
		return true;
	}

    function BeginState()
    {
        BeamDirection = vect(0,0,-1);
        DamageLocation = MarkLocation - BeamDirection * 200.0;
    }

    function SpawnEffect()
    {
        local DarkIonEffect IonBeamEffect;
        local Actor Other;
        local Vector HitLocation, HitNormal, Top, CP;

        Other = Trace(HitLocation, HitNormal, MarkLocation + vect(0,0,10000), MarkLocation, false);

		Top = MarkLocation;
		Top.Z = FMax(HitLocation.Z,Location.Z);

        IonBeamEffect = Spawn(IonEffectClass,,, Top);
        if (IonBeamEffect != None)
            IonBeamEffect.AimAt(MarkLocation, Vect(0,0,1));

        if ( Instigator != None )
			CP = Normal(vect(0,0,1) Cross (Location - Instigator.Location));
		else
			CP = vect(1,0,0);

		CP *= 0.5 * (Location.Z - MarkLocation.Z);

        Other = Trace(HitLocation, HitNormal, Top + CP, MarkLocation, false);
        if ( Other == None )
        {
			IonBeamEffect = Spawn(IonEffectClass,,, Top + CP);
			if (IonBeamEffect != None)
				IonBeamEffect.AimAt(MarkLocation, Vect(0,0,1));
		}

        Other = Trace(HitLocation, HitNormal, Top - CP, MarkLocation, false);
        if ( Other == None )
        {
			IonBeamEffect = Spawn(IonEffectClass,,, Top - CP);
			if (IonBeamEffect != None)
				IonBeamEffect.AimAt(MarkLocation, Vect(0,0,1));
		}
    }

    function ShakeView()
    {
        local Controller C;
        local PlayerController PC;
        local float Dist, Scale;

        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            PC = PlayerController(C);
            if ( PC != None && PC.ViewTarget != None && PC.ViewTarget.Base != None )
            {
                Dist = VSize(DamageLocation - PC.ViewTarget.Location);
                if ( Dist < DamageRadius * 2.0)
                {
                    if (Dist < DamageRadius)
                        Scale = 1.0;
                    else
                        Scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
                    C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
                }
            }
        }
    }

	function PlayGlobalSound(sound S)
	{
		local PlayerController P;

 		ForEach DynamicActors(class'PlayerController', P)
			P.ClientPlaySound(S);
	}

    function EndState()
    {
		if ( (Instigator != None) && (Painter(Instigator.Weapon) != None) )
			Instigator.Weapon.CheckOutOfAmmo();

		if ( Fear != None )
			Fear.Destroy();
	}

Begin:


	if ( (Instigator != None) && (Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.Team != None) )
		Fear.TeamNum = Instigator.PlayerReplicationInfo.Team.TeamIndex;


    SpawnEffect();
	PlayGlobalSound(FireSound);


/*
    ShakeView();
    HurtRadius(Damage, DamageRadius*0.125, DamageType, MomentumTransfer, DamageLocation);
    Sleep(0.5);
	PlayGlobalSound(sound'WeaponSounds.redeemer_explosionsound');
    HurtRadius(Damage, DamageRadius*0.300, DamageType, MomentumTransfer, DamageLocation);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.475, DamageType, MomentumTransfer, DamageLocation);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.650, DamageType, MomentumTransfer, DamageLocation);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.825, DamageType, MomentumTransfer, DamageLocation);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*1.000, DamageType, MomentumTransfer, DamageLocation);
*/
    GotoState('StartAntiGrav');
}


/************************************/
state StartAntiGrav
{
    simulated function BeginState()
    {
        StrengthFadeTimeIndex = Level.TimeSeconds;



        bProjTarget = false;
        SetCollision(false, false, false);
        SetTimer(EffectsSpawnTime, false);

        LightRadius = 1.0;
    }

    simulated function Timer()
    {
        SpawnVisualEffects();
    }

    simulated function Tick(float DeltaTime)
    {
//        local float StrengthScale;

//        StrengthScale = (Level.TimeSeconds - StrengthFadeTimeIndex) / BuildUpTime;
//        SuckInActors(QuantumGravity * StrengthScale, QuantumRange * StrengthScale, DeltaTime);
        LightRadius = (default.LightRadius * (BuildUpTime - LatentFloat)) / BuildUpTime;
    }

    simulated function EndState()
    {
        Acceleration = vect(0.0, 0.0, 0.0);
    }

Begin:
//    QuantumEmitter = Spawn(class'QuantumEmitter', self);
//    QuantumEmitter.LifeSpan = (BuildUpTime + ActiveTime) + CalmDownTime;
//    PlaySound(QuantumStartSound, SLOT_Misc, 255.0,, 6000.0);
//    Sleep(BuildUpTime);
    GotoState('AntiGrav');
    stop;
}

state AntiGrav
{
    function Tick(float DeltaTime)
    {
        AntiGravActors(QuantumGravity, QuantumRange, DeltaTime);

        if(Level.TimeSeconds >= EndTime)
        {
            GotoState('StopAntiGrav');
        }

    }

    function BeginState()
    {
//        QuantumMainLightning = Spawn(class'QuantumFX', self);
        Timer();
    }

    function Timer()
    {
        local Sound S;

        S = AntiGravSound;

        PlaySound(S, SLOT_Misc, 255.0,, 6000.0);

        if(LatentFloat > GetSoundDuration(S))
        {
            SetTimer(GetSoundDuration(S) + FRand(), false);
        }
    }

    function EndState()
    {
        SetTimer(0.0, false);
    }

Begin:
    EndTime = Level.TimeSeconds + ActiveTime;
    Sleep(ActiveTime);
    GotoState('StopAntiGrav');
    stop;
}

state StopAntiGrav
{
    function BeginState()
    {

        if(QuantumEmitter != none)
        {
            QuantumEmitter.Kill();
        }

        if(QuantumLightning != none)
        {
            QuantumLightning.Kill();
        }

        if(QuantumMainLightning != none)
        {
            QuantumMainLightning.Kill();
        }

        StrengthFadeTimeIndex = Level.TimeSeconds;
    }

    function Tick(float DeltaTime)
    {
        local float StrengthScale;

        StrengthScale = 1.0 - ((Level.TimeSeconds - StrengthFadeTimeIndex) / CalmDownTime);
        AntiGravActors(-QuantumGravity*2, QuantumRange, DeltaTime);


        LightRadius = (default.LightRadius * LatentFloat) / CalmDownTime;

    }

Begin:
    Sleep(CalmDownTime);
    GotoState('Ready');
    stop;
}
/***********************************/
simulated function SpawnVisualEffects()
{
    local float TimeRemaining;

//    PlaySound(QuantumAmbientSound, SLOT_Interact, 255.0,, 6000.0);

    if(Level.NetMode == NM_DedicatedServer)
    {
        return;
    }
    TimeRemaining = (BuildUpTime - EffectsSpawnTime) + ActiveTime;
/*
    QuantumLightning = Spawn(class'QuantumMainLightning', self);
*/
}

function bool IsVisible(Actor Other)
{
    return !Other.bHidden && (((((Other.DrawType == 2) || Other.DrawType == 8) || Other.DrawType == 1) || Other.DrawType == 7) || Other.DrawType == 4) || Other.DrawType == 5;
}

function bool IsMovable(Actor Other)
{
    if(Other.bStatic || Other.bNoDelete)
    {
        return false;
    }

    if(Other.IsA('GameObject') && (Other.Physics == PHYS_None) || Other.Physics == PHYS_Rotating)
    {
        return Other.IsInState('dropped') || Other.IsInState('home');
    }

    if(Other.IsA('UnrealPawn') && ((((((Other.Physics == PHYS_Walking) || Other.Physics == PHYS_Falling) || Other.Physics == PHYS_Swimming) || Other.Physics == PHYS_Flying) || Other.Physics == PHYS_Spider) || Other.Physics == PHYS_Ladder) || Other.Physics == PHYS_KarmaRagDoll)
    {
        return true;
    }

    if(Other.IsA('Pickup') && Pickup(Other).bDropped)
    {
        return true;
    }

    return ((Other.Physics == PHYS_Projectile) || Other.Physics == PHYS_Falling) || Other.Physics == PHYS_Karma;
}


function AntiGravActors(float Gravity, float Range, float DeltaTime)
{
    local Pawn thisPawn;
    local Vector Dir, ActorLocation, TargetLocation;
    local float dist, Strength;

    DamageTime += DeltaTime;

    Dir = vect(0,0,1);

    foreach AllActors(class'Pawn', thisPawn)
    {

        TargetLocation = MarkLocation;
        TargetLocation.Z = 0.0;

        ActorLocation = thisPawn.Location;

        ActorLocation.Z = 0.0;
        dist = VSize(TargetLocation - ActorLocation);

        if(dist > Range){
            continue;
        }

        Strength = (Gravity/2) + (FRand()*Gravity/2);// * DeltaTime);// * (2.10 - (float(2) * Square(dist / Range)));

        Strength = Strength*DeltaTime*110;

        //log("Strength="$Strength$"DeltaTime="$DeltaTime$"Str*Delta="$StrDelta);

        if((thisPawn.Physics == PHYS_Karma) || thisPawn.Physics == PHYS_KarmaRagDoll )
        {
            if(thisPawn.IsA('SVehicle'))
            {
                Strength = Strength;//SVehicle(thisPawn).VehicleMass  ;
            }

            if(!thisPawn.KIsAwake())
            {
                thisPawn.KWake();
            }

            //thisPawn.KAddImpulse(((Dir * Strength/1.5) * thisPawn.Mass) * thisPawn.KGetMass(), ActorLocation, 'bip01 Spine');
            thisPawn.KAddImpulse( Dir * Strength  * thisPawn.KGetMass() * 73 , ActorLocation, 'bip01 Spine');
        } else {

            if(thisPawn != none)
            {
                if((thisPawn.Physics == PHYS_Walking ) && Dir.Z < float(0))
                {
                    Dir.Z = KickUpSpeed / Strength;
                }
                thisPawn.AddVelocity(Dir * Strength);
                thisPawn.DelayedDamageInstigatorController = Instigator.Controller;
            } else {

                if((thisPawn.Physics == PHYS_None) || thisPawn.Physics == PHYS_Rotating)
                {
                    if(thisPawn.IsA('GameObject') && thisPawn.IsInState('home'))
                    {
                        thisPawn.GotoState('dropped');
                    }
                    thisPawn.SetPhysics(PHYS_Falling);
                    thisPawn.Velocity = vect(0.0, 0.0, 1.0) * KickUpSpeed;
                }


                thisPawn.Velocity += (Dir * Strength);


            }
        }





    }


}



function bool IsFiring()
{
    return false;
}

defaultproperties
{
     AntiGravSound=Sound'ONSVehicleSounds-S.PowerNode.PwrNodeActive01'
     FireSound=Sound'WeaponSounds.TAGRifle.IonCannonBlast'
     IonEffectClass=Class'W_DarkMatter.DarkIonEffect'
     Damage=150
     MomentumTransfer=150000.000000
     DamageRadius=2000.000000
     DamageType=Class'XWeapons.DamTypeIonBlast'
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     QuantumGravity=15.000000
     QuantumRange=3500.000000
     InitialDelay=1.000000
     BuildUpTime=2.000000
     EffectsSpawnTime=1.000000
     ActiveTime=10.000000
     CalmDownTime=3.000000
     DampenFactor=0.500000
     DampenFactorParallel=0.750000
     KickUpSpeed=80.000000
     KillRadius=150.000000
     DrawType=DT_Mesh
     bHidden=True
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'Weapons.IonCannon'
     TransientSoundVolume=1.000000
     TransientSoundRadius=2000.000000
     bRotateToDesired=True
     RotationRate=(Pitch=15000,Yaw=15000,Roll=15000)
}
