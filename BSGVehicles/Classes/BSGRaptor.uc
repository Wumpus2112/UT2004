//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BSGRaptor extends ONSAttackCraft;

#exec OBJ LOAD FILE=CicadaSnds.uax

var bool    bHeatSeeker;
var byte    LastThrust;         // The last throttle position
var float   DesiredPitch;
var float   CurrentPitch;
var float   PitchTime;

var int     LastYaw, DesiredYaw;
var float   YawTime;

var array<ONSDecoy> Decoys;

// Hud Elements

var float LastHudRenderTime;    // Needed for animations
var bool  bLastLockType;

var localized string CoPilotLabel;

var bool bFreelanceStart;

// AI hint
function bool ImportantVehicle()
{
    return !bFreelanceStart;
}

simulated function ClientKDriverEnter(PlayerController PC)
{
    Super.ClientKDriverEnter(PC);
}

function KDriverEnter(Pawn P)
{
    Super.KDriverEnter(P);
}

 /*
simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if (Role == ROLE_Authority)
    {
        if (WeaponPawns[0]!=None)
            WeaponPawns[0].Gun.SetOwner(self);

        if (Weapons.Length == 2 && ONSLinkableWeapon(Weapons[0]) != None)
    {
        ONSLinkableWeapon(Weapons[0]).ChildWeapon = Weapons[1];
        if (ONSDualACSideGun(Weapons[1]) != None)
            ONSDualACSideGun(Weapons[1]).bSkipFire = True;

            if (ONSDualACSideGun(Weapons[0]) != None)
                ONSDualACSideGun(Weapons[0]).bFiresRight = true;
        }

    }
}
*/
function DriverLeft()
{
    Super.DriverLeft();
}

simulated function Tick(float DeltaTime)
{
    local int       Yaw;
    local actor     HitActor;
    local vector    HitLocation, HitNormal;
    local float GroundDist;

    super.Tick(DeltaTime);

    if ( !IsVehicleEmpty() )
        Enable('tick');

    if ( (Bot(Controller) != None) && !Controller.InLatentExecution(Controller.LATENT_MOVETOWARD)  )
    {
        if ( Rise < 0 )
        {
            if ( Velocity.Z < 0 )
            {
                if ( Velocity.Z < -2000 )
                    Rise = -0.1;

                // FIX - use dist to adjust down as get closer
                HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,2000), Location, false);
                if ( HitActor != None )
                {
                    GroundDist = Location.Z - HitLocation.Z;
                    if ( GroundDist/(-1*Velocity.Z) < 0.85 )
                        Rise = 1.0;
                }
            }
        }
        else if ( Rise == 0 )
        {
            if ( !FastTrace(Location - vect(0,0,300),Location) )
                Rise = FClamp((-1 * Velocity.Z)/MaxRiseForce,0.f,1.f);
        }
    }
    // Adjust the various effects

    if (Level.NetMode != NM_DedicatedServer)
    {
        if (LastThrust != CopState.ServerThrust)
        {
            if (CopState.ServerThrust<128)
                DesiredPitch = -10240;
            else if (CopState.ServerThrust>128)
                DesiredPitch = 10240;
            else
                DesiredPitch = 0;

            PitchTime = 1.0;
            LastThrust = CopState.ServerThrust;
        }
        if (CurrentPitch != DesiredPitch)
        {

            CurrentPitch += (DesiredPitch - CurrentPitch) * (DeltaTime / PitchTime);
            PitchTime -= DeltaTime;

            if (PitchTime<=0 || DesiredPitch == CurrentPitch)
            {
                PitchTime = 0.0;
                DesiredPitch = CurrentPitch;
            }
        }

        Yaw = Rotation.Yaw; // Give some deadzone
        if (Yaw != LastYaw)
        {
            if ( (Yaw>0 && LastYaw>0) || (Yaw<0 && LastYaw<0) ) // Skip sign changes
            {
                if (LastYaw>Yaw)
                    DesiredYaw=-6144;
                else
                    DesiredYaw=6144;

                YawTime = 1.0;
            }
        }
        else
        {
            DesiredYaw=0;
            YawTime = 1.0;
        }

        LastYaw = Yaw;
    }
}

simulated event DrivingStatusChanged()
{
    local vector RotX, RotY, RotZ;
    local int i;

    super(ONSChopperCraft).DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
    {
        GetAxes(Rotation,RotX,RotY,RotZ);

        if (TrailEffects.Length == 0)
        {
            TrailEffects.Length = TrailEffectPositions.Length;

            for(i=0;i<TrailEffects.Length;i++)
                if (TrailEffects[i] == None)
                {
                    TrailEffects[i] = spawn(TrailEffectClass, self,, Location + (TrailEffectPositions[i] >> Rotation) );
                    TrailEffects[i].SetBase(self);
                    TrailEffects[i].SetRelativeRotation( rot(-16384,32768,0) );
                }
        }
    }
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
        {
            for(i=0;i<TrailEffects.Length;i++)
               TrailEffects[i].Destroy();

            TrailEffects.Length = 0;
        }
    }
}

// Check all of the active decoys and see if any take effect.

event bool VerifyLock(actor Aggressor, out actor NewTarget)
{
    local int i;

    for (i=0;i<Decoys.Length;i++)
    {
        if ( Decoys[i].CheckRange(Aggressor) )
        {
            NewTarget = Decoys[i];
            return false;
        }
    }

    return true;
}

function Vehicle FindEntryVehicle(Pawn P)
{
    local Bot B, S;

    B = Bot(P.Controller);
    if ( (B == None) || !IsVehicleEmpty() || (WeaponPawns[0].Driver != None) )
        return Super.FindEntryVehicle(P);

    for ( S=B.Squad.SquadMembers; S!=None; S=S.NextSquadMember )
    {
        if ( (S != B) && (S.RouteGoal == self) && S.InLatentExecution(S.LATENT_MOVETOWARD)
            && ((S.MoveTarget == self) || (Pawn(S.MoveTarget) == None)) )
            return WeaponPawns[0];
    }
    return Super.FindEntryVehicle(P);
}


DefaultProperties
{
    //mesh=SkeletalMesh'RP.RP'
     mesh=mesh'RP.RP'

    RedSkin=texture'BSGVehicles.BSGVehicles.Raptor'
    BlueSkin=texture'BSGVehicles.BSGVehicles.Raptor'

    Begin Object Class=KarmaParamsRBFull Name=KParams0
        KStartEnabled=True
        KFriction=0.5
        KLinearDamping=0.0
        KAngularDamping=0.0
        KImpactThreshold=300
        bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        bKStayUpright=True
        bKAllowRotate=True
        KInertiaTensor(0)=1.0
        KInertiaTensor(1)=0.0
        KInertiaTensor(2)=0.0
        KInertiaTensor(3)=3.0
        KInertiaTensor(4)=0.0
        KInertiaTensor(5)=3.5
        KCOMOffset=(X=-0.25,Y=0.0,Z=0.0)
        KActorGravScale=0.0
        KMaxSpeed=2000.0
        bDestroyOnWorldPenetrate=True
        bDoSafetime=True
        Name="KParams0"
    End Object

    //CollisionRadius=+240.0

    MaxRiseForce=200.0
    MaxStrafeForce=65.0
    MaxThrustForce=80.0
    LongDamping=0.3

    Health=500
    HealthMax=500

    DriverWeapons(0)=(WeaponClass=class'Onslaught.ONSAttackCraftGun',WeaponBone=gun);

    TPCamWorldOffset=(Z=350)

    RollTorqueMax=100
    RollTorqueStrafeFactor=100
    RollTorqueTurnFactor=750

    TrailEffectPositions(0)=(X=250,Y=-20,Z=10);
    TrailEffectPositions(1)=(X=250,Y=20,Z=10);

    IdleSound=sound'CicadaSnds.CicadaIdle'
    StartUpSound=sound'CicadaSnds.CicadaStartUp'
    ShutDownSound=sound'CicadaSnds.CicadaShutDown'

    SoundVolume=255
    SoundRadius=300

    VehiclePositionString="in a Raptor"
    VehicleNameString="Raptor"

    EntryPosition=(X=0,Y=0,Z=-20)
    EntryRadius=300

    ExitPositions(0)=(X=0,Y=-400,Z=100)
    ExitPositions(1)=(X=0,Y=400,Z=100)
    ExitPositions(2)=(X=-600,Y=0,Z=100)
    PushForce=200000.0

    DestructionLinearMomentum=(Min=250000,Max=400000)
    DestructionAngularMomentum=(Min=100,Max=150)
    DisintegrationHealth=-100
    DisintegrationEffectClass=class'OnslaughtBP.ONSDualACDeathExp'

    CoPilotLabel="Passenger"
}
