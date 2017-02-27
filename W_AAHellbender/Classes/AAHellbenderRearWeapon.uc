//-----------------------------------------------------------
//
//-----------------------------------------------------------
class AAHellbenderRearWeapon extends ONSWeapon;


#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx
#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx
#exec OBJ LOAD FILE=..\Textures\TurretParticles.utx

var class<ONSTurretBeamEffect> BeamEffectClass[2];

//var class<ONSChargeBeamEffect> BeamEffectClass;
var float StartHoldTime;
var float MaxHoldTime; //wait this long between shots for full damage
var float DamageScale, MinDamageScale;
var bool bHoldingFire;
var sound ChargingSound, ChargedLoop;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.BeamBolt1a');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_core');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');
    L.AddPrecacheMaterial(Material'EpicParticles.Beams.HotBolt04aw');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.BurnFlare');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.BeamBolt1a');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_core');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');
    Level.AddPrecacheMaterial(Material'EpicParticles.Beams.HotBolt04aw');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.BurnFlare');

    Super.UpdatePrecacheMaterials();
}

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    local int Damage;

    X = Vector(Dir);
    End = Start + TraceRange * X;

    //skip past vehicle driver
    if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
    {
        ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
        Other = Trace(HitLocation, HitNormal, End, Start, True);
        ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
        Other = Trace(HitLocation, HitNormal, End, Start, True);

    if (Other != None)
    {
    if (!Other.bWorldGeometry)
        {
            Damage = (DamageMin + Rand(DamageMax - DamageMin));
            if (ONSPowerCore(Other) == None && ONSPowerNodeEnergySphere(Other) == None)  // Sweet Hackaliciousness
                Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
            HitNormal = vect(0,0,0);
        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

    HitCount++;
    LastHitLocation = HitLocation;
    SpawnHitEffects(Other, HitLocation, HitNormal);
}

state InstantFireMode
{
    simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
    {
        local ONSTurretBeamEffect Beam;

        if (Level.NetMode != NM_DedicatedServer)
        {
            if (Role < ROLE_Authority)
            {
                CalcWeaponFire();
                DualFireOffset *= -1;
            }

            if (!Level.bDropDetail && Level.DetailMode != DM_Low)
            {
                if (DualFireOffset < 0)
                    PlayAnim('RightFire');
                else
                    PlayAnim('LeftFire');
            }

            Beam = Spawn(BeamEffectClass[Team],,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
            BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
            BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
            BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
            BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
            Beam.SpawnEffects(HitLocation, HitNormal);
        }
    }
}

defaultproperties
{
     BeamEffectClass(0)=Class'Onslaught.ONSTurretBeamEffect'
     BeamEffectClass(1)=Class'Onslaught.ONSTurretBeamEffectBlue'
     MaxHoldTime=2.500000
     MinDamageScale=0.150000
     ChargingSound=Sound'ONSVehicleSounds-S.PRV.PRVChargeUp'
     ChargedLoop=Sound'ONSVehicleSounds-S.PRV.PRVChargeLoop'
     YawBone="REARgunBASE"
     PitchBone="REARgunTURRET"
     PitchUpLimit=15000
     PitchDownLimit=57500
     WeaponFireAttachmentBone="Dummy02"
     GunnerAttachmentBone="REARgunBASE"
     WeaponFireOffset=25.000000
     DualFireOffset=15.000000
     bInstantRotation=True
     bInstantFire=True
     bDualIndependantTargeting=True
     bShowChargingBar=True
     bDoOffsetTrace=True
     RedSkin=Shader'VMVehicles-TX.NEWprvGroup.newPRVredSHAD'
     BlueSkin=Shader'VMVehicles-TX.NEWprvGroup.newPRVshad'
     FireInterval=0.300000
     FlashEmitterClass=Class'Onslaught.ONSPRVRearGunCharge'
     FireSoundClass=Sound'WeaponSounds.Misc.instagib_rifleshot'
     FireForce="Laser01"
     DamageType=Class'Onslaught.DamTypeTurretBeam'
     DamageMin=30
     DamageMax=30
     TraceRange=20000.000000
     Momentum=50000.000000
     AIInfo(0)=(bInstantHit=True,aimerror=820.000000)
     Mesh=SkeletalMesh'ONSWeapons-A.PRVrearGUN'
     DrawScale=0.800000
     CollisionRadius=50.000000
     CollisionHeight=70.000000
}
