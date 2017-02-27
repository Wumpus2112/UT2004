//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Bike extends ONSWheeledCraft;

var bool ClientDoBikeJump;
var float BikeJumpForce;
var bool ReallyInAir;
var() float JumpDuration;
var() float JumpForceMag;
var float JumpCountdown;
var float JumpDelay;
var float LastJumpTime;
var bool DoBikeJump;
var bool OldDoBikeJump;
var Rotator ArmDriveL;
var Rotator ArmDriveR;
var Rotator NeckDrive;
var Rotator ThighDriveL;
var Rotator ThighDriveR;
var Rotator CalfDriveL;
var Rotator CalfDriveR;
var() Material RedSkinB;
var() Material BlueSkinB;
var() bool bHeadLight;

var ONSHeadlightCorona Headlight;
var Vector HeadlightOffset;
var bool bNoWeapons;
var() bool MouseSteer;
var bool bLifeLimited;

var float LastHudRenderTime;
var bool bLastLockType;

var(Gfx) Vector RechargeOrigin;
var(Gfx) Vector RechargeSize;
var Emitter BoostAura;
var float MultiSpawnDelay;
var() float UprightStiffness;
var() float UprightDamping;


simulated event SVehicleUpdateParams()
{
    super.SVehicleUpdateParams();
    KSetStayUprightParams(UprightStiffness, UprightDamping);
    //return;
}

function Pawn CheckForHeadShot(Vector loc, Vector ray, float AdditionalScale)
{
    local Vector X, Y, Z, newray;

    GetAxes(Rotation, X, Y, Z);
    // End:0x7D
    if(Driver != none)
    {
        newray = ray;
        newray.Z = 0.0;
        // End:0x7D
        if((Abs(newray Dot X) < 0.70) && Driver.IsHeadShot(loc, ray, AdditionalScale))
        {
            return Driver;
        }
    }
    return none;
    //return;
}

simulated event TeamChanged()
{
    super(ONSVehicle).TeamChanged();
    // End:0x3D
    if((Team == 0) && RedSkin != none)
    {
        Skins[0] = RedSkin;
        Skins[1] = RedSkinB;
    }
    // End:0x71
    else
    {
        // End:0x71
        if((Team == 1) && BlueSkin != none)
        {
            Skins[0] = BlueSkin;
            Skins[1] = BlueSkinB;
        }
    }
    //return;
}

/*
function bool Dodge(Engine.Actor.EDoubleClickDir DoubleClickMove)
{
    Rise = 1.0;
    return true;
    //return;
}
*/
simulated event DrivingStatusChanged()
{
    super.DrivingStatusChanged();
    JumpCountdown = 0.0;
    //return;
}

simulated event KApplyForce(out Vector Force, out Vector Torque)
{
    local Vector X, Y, Z;

    GetAxes(Rotation, X, Y, Z);
    super(SVehicle).KApplyForce(Force, Torque);
    // End:0x5B
    if(bDriving && JumpCountdown > 0.0)
    {
        Force += (vect(0.0, 0.0, 1.0) * JumpForceMag);
    }
    // End:0xAC
    if(ClientDoBikeJump)
    {
        Force += (Z * BikeJumpForce);
        // End:0xA4
        if(bVehicleOnGround)
        {
            Torque += ((vect(0.0, 0.0, 1.0) * Steering) * -AirTurnTorque);
        }
        ClientDoBikeJump = false;
    }
    //return;
}

simulated function CheckJumpDuck()
{

    // End:0xE2
    if(((JumpCountdown <= 0.0) && Rise > float(0)) && (Level.TimeSeconds - JumpDelay) >= LastJumpTime)
    {
      //  UnresolvedNativeFunction_97(JumpSound,, 1.0);
        // End:0x6C
        if(Role == ROLE_Authority)
        {
            DoBikeJump = !DoBikeJump;
        }
        // End:0x7F
        if(!ClientDoBikeJump)
        {
            ClientDoBikeJump = true;
        }
        // End:0xB3
        if(Level.NetMode != NM_DedicatedServer)
        {
//            JumpEffect = UnresolvedNativeFunction_97(class'BikeJumpEffect');
//            JumpEffect.SetBase(self);
        }
        // End:0xCE
        if(AIController(Controller) != none)
        {
            Rise = 0.0;
        }
        LastJumpTime = Level.TimeSeconds;
    }
    //return;
}

simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);
    JumpCountdown -= DeltaTime;
    CheckJumpDuck();
    // End:0x46
    if(DoBikeJump != OldDoBikeJump)
    {
        JumpCountdown = JumpDuration;
        OldDoBikeJump = DoBikeJump;
    }
    // End:0x70
    if(!bDoStuntInfo && bVehicleOnGround)
    {
        LastOnGroundTime = Level.TimeSeconds;
    }
    ReallyInAir = (Level.TimeSeconds - LastOnGroundTime) > 0.20;
    // End:0xBD
    if(MouseSteer && Level.NetMode != NM_DedicatedServer)
    {
        AdjustForMouseSteering();
    }
   // TurboBoostStuff(DeltaTime);
  //  MineStuff(DeltaTime);
  //  SpawnStuff(DeltaTime);
    //return;
}

simulated event UpdateVehicle(float DeltaTime)
{
    // End:0x0F
    if(MouseSteer)
    {
        AdjustForMouseSteering();
    }
    super(SVehicle).UpdateVehicle(DeltaTime);
    //return;
}

function AdjustForMouseSteering()
{
    local Vector Dir;
    local int YawDiff;
    local float NewSteering;
    local int PitchDiff;
    local float NewRise;

    // End:0x0D
    if(Controller == none)
    {
        return;
    }
    YawDiff = (Rotation.Yaw - Controller.Rotation.Yaw) & 65535;
    // End:0x54
    if(YawDiff > 32768)
    {
        YawDiff -= 65536;
    }
    NewSteering = float(YawDiff) / 12000.0;
    FClamp(NewSteering, -1.0, 1.0);
    Dir = vector(Rotation);
    // End:0xA7
    if((Dir Dot Velocity) < float(0))
    {
        NewSteering = -NewSteering;
    }
    Steering = NewSteering;
    // End:0x134
    if(ReallyInAir)
    {
        PitchDiff = (Rotation.Pitch - Controller.Rotation.Pitch) & 65535;
        // End:0x102
        if(PitchDiff > 32768)
        {
            PitchDiff -= 65536;
        }
        NewRise = float(-PitchDiff) / 12000.0;
        FClamp(NewRise, -1.0, 1.0);
        Rise = NewRise;
    }
    //return;
}

simulated event KImpact(Actor Actor, Vector pos, Vector impactVel, Vector impactNorm)
{
    super.KImpact(Actor, pos, impactVel, impactNorm);
    //return;
}

function KDriverEnter(Pawn P)
{
    super(ONSVehicle).KDriverEnter(P);
    // End:0x25
    if(StartUpSound != none)
    {
       // UnresolvedNativeFunction_97(StartUpSound, 0, 2.0);
    }
    // End:0x37
    if(bHeadLight == false)
    {
        SwitchToLastWeapon();
    }
   // Weapons[0].UnresolvedNativeFunction_97('Deploy');
    //return;
}

function bool ImportantVehicle()
{
    return true;
    //return;
}
/*
simulated function Destroyed()
{
    // End:0x30
    if(Level.NetMode != NM_DedicatedServer)
    {
        // End:0x30
        if(Headlight != none)
        {
            Headlight.Destroy();
        }
    }
    // End:0x47
    if(DumGunL != none)
    {
        DumGunL.Destroy();
    }
    // End:0x5E
    if(DumGunR != none)
    {
        DumGunR.Destroy();
    }
    // End:0x75
    if(BoostAura != none)
    {
        BoostAura.Destroy();
    }
    super.Destroyed();
    //return;
}
*/
simulated function AttachDriver(Pawn P)
{
    super(Vehicle).AttachDriver(P);
    NeckDrive.Yaw = -10000;
    P.SetBoneRotation('Bip01 Head', NeckDrive);
    ArmDriveL.Yaw = -5000;
    ArmDriveL.Pitch = -10000;
    P.SetBoneRotation('Bip01 L UpperArm', ArmDriveL);
    ArmDriveR.Yaw = -5000;
    ArmDriveR.Pitch = 10000;
    P.SetBoneRotation('Bip01 R UpperArm', ArmDriveR);
    ThighDriveL.Pitch = -10000;
    P.SetBoneRotation('Bip01 L Thigh', ThighDriveL);
    ThighDriveR.Pitch = 10000;
    P.SetBoneRotation('Bip01 R Thigh', ThighDriveR);
    CalfDriveL.Pitch = 6500;
    CalfDriveL.Yaw = -6500;
    P.SetBoneRotation('Bip01 L Calf', CalfDriveL);
    CalfDriveR.Pitch = -6500;
    CalfDriveR.Yaw = -6500;
    P.SetBoneRotation('Bip01 R Calf', CalfDriveR);
    // End:0x189
    if(bLifeLimited == true)
    {
        bLifeLimited = false;
        LifeSpan = 0.0;
    }
    //return;
}

simulated function DetachDriver(Pawn P)
{
    Driver.SetBoneRotation('Bip01 Head');
    Driver.SetBoneRotation('Bip01 L UpperArm');
    Driver.SetBoneRotation('Bip01 R UpperArm');
    Driver.SetBoneRotation('Bip01 L Thigh');
    Driver.SetBoneRotation('Bip01 R Thigh');
    Driver.SetBoneRotation('Bip01 L Calf');
    Driver.SetBoneRotation('Bip01 R Calf');
//    Weapons[0].UnresolvedNativeFunction_97('UnDeploy');
    // End:0xBE
    if(bLifeLimited == false)
    {
        bLifeLimited = true;
        LifeSpan = 60.0;
    }
    //return;
}

function bool KDriverLeave(bool bForceLeave)
{
    return super(ONSVehicle).KDriverLeave(true);
    //return;
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    KSetStayUpright(true, true);
    KSetStayUprightParams(UprightStiffness, UprightDamping);
    //return;
}

simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    // End:0x1A
    if(MouseSteer == true)
    {
        bFollowLookDir = true;
    }
    //return;
}

/*
exec function SwitchToLastWeapon()
{
    // End:0x1D
    if(bHeadLight == false)
    {
        bHeadLight = true;
        HeadLightsOn();
    }
    // End:0x2B
    else
    {
        bHeadLight = false;
        HeadLightsOn();
    }
    //return;
}

simulated function HeadLightsOn()
{
    // End:0xCD
    if((Level.NetMode != NM_DedicatedServer) && bHeadLight == true)
    {
        Headlight = UnresolvedNativeFunction_97(class'ONSHeadlightCorona', self,, Location + (HeadlightOffset >> Rotation));
        // End:0xCD
        if(Headlight != none)
        {
            Headlight.SetBase(self);
            Headlight.SetRelativeRotation(rot(0, 0, 0));
            Headlight.Skins[0] = HeadlightCoronaMaterial;
            Headlight.ChangeTeamTint(Team);
            Headlight.MaxCoronaSize = HeadlightCoronaMaxSize * Level.HeadlightScaling;
        }
    }
    // End:0x100
    if((Level.NetMode != NM_DedicatedServer) && bHeadLight == false)
    {
        Headlight.Destroy();
    }
    //return;
}
*/
function DriverLeft()
{
    super(ONSVehicle).DriverLeft();
    // End:0x20
    if(ShutDownSound != none)
    {
//        UnresolvedNativeFunction_97(ShutDownSound, 0, 0.50);

//////////////////////////////////
//
// NEED TO FIX THIS FUNCTION!!!
//
//////////////////////////////////

    }
    // End:0x32
    if(bHeadLight == true)
    {
        SwitchToLastWeapon();
    }
    //return;
}

function VehicleCeaseFire(bool bWasAltFire)
{
    super(ONSVehicle).VehicleCeaseFire(bWasAltFire);
    //return;
}
function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType)
{

    if((instigatedBy != none) && instigatedBy.GetTeamNum() == (GetTeamNum()))
    {
        return;
    }
    super(ONSVehicle).TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
    //return;
}

function EjectDriver()
{
    local Pawn OldPawn;
    local Vector EjectVel;

    OldPawn = Driver;
    KDriverLeave(true);
    // End:0x1F
    if(OldPawn == none)
    {
        return;
    }
    EjectVel = Velocity;
    EjectVel.Z = EjectVel.Z + EjectMomentum;
    EjectVel.X = EjectVel.X + EjectMomentum;
    OldPawn.Velocity = EjectVel;
    //return;
}
/*
function SpawnStuff(float DeltaTime)
{
    // End:0x12
    if(Role != ROLE_Authority)
    {
        return;
    }
    // End:0x1F
    if(ParentFactory == none)
    {
        return;
    }
    // End:0x30
    if(MultiSpawnDelay < -100.0)
    {
        return;
    }
    // End:0x4E
    if(MultiSpawnDelay > 0.0)
    {
        MultiSpawnDelay -= DeltaTime;
    }
    // End:0xAB
    else
    {
        // End:0xA0
        if(ParentFactory.VehicleCount < ParentFactory.MaxVehicleCount)
        {
            ParentFactory.VehicleDestroyed(self);
            ++ ParentFactory.VehicleCount;
            ParentFactory.Trigger(self, self);
        }
        MultiSpawnDelay = -1000.0;
    }
    //return;
}

function MineStuff(float DeltaTime)
{
    // End:0x12
    if(Role != ROLE_Authority)
    {
        return;
    }
    // End:0x61
    if(MineCount < MaxMines)
    {
        MineMeter += ((float(MaxMines) * DeltaTime) / 30.0);
        // End:0x5E
        if(MineMeter > 1.0)
        {
            ++ MineCount;
            MineMeter = 0.0;
        }
    }
    // End:0x6C
    else
    {
        MineMeter = 0.0;
    }
    //return;
}
*/



/*
function StartBoost()
{
    // End:0x29
    if(BoostAura == none)
    {
        BoostAura = UnresolvedNativeFunction_97(class'LancerBoostAuraEffect',,,);
        BoostAura.SetBase(self);
    }
    // End:0x99
    if(Role == ROLE_Authority)
    {
        bBoosting = true;
        KarmaParams(KParams).KMaxSpeed += (KarmaParams(KParams).default.KMaxSpeed + TurboBoostSpeedAdd);
        UnresolvedNativeFunction_97(sound'LancerSonicBoom02', 0, 10.0 * TransientSoundVolume,, 900.0,, true);
        SpeedLost = 0.0;
    }
    //return;
}

function EndBoost()
{
    local int i;

    // End:0x37
    if(Role == ROLE_Authority)
    {
        bBoosting = false;
        TurboBoostRechargeDelay = default.TurboBoostRechargeDelay;
        TimeOfBoostEnd = Level.TimeSeconds;
    }
    // End:0x8C
    if(BoostAura != none)
    {
        i = 0;
        J0x49:
        // End:0x8C [Loop If]
        if(i < BoostAura.Emitters.Length)
        {
            BoostAura.Emitters[i].RespawnDeadParticles = false;
            ++ i;
            // [Loop Continue]
            goto J0x49;
        }
    }
    //return;
}


function TurboBoostStuff(float DeltaTime)
{
    local LancerFlameProjectile LFP;
    local Vector TempVector;

    // End:0xFB
    if(!bBoosting)
    {
        // End:0xF8
        if(Role == ROLE_Authority)
        {
            // End:0x7F
            if((Level.TimeSeconds - TimeOfBoostEnd) <= SlowDownTime)
            {
                KarmaParams(KParams).KMaxSpeed -= ((TurboBoostSpeedAdd * DeltaTime) / SlowDownTime);
                SpeedLost += ((TurboBoostSpeedAdd * DeltaTime) / SlowDownTime);
            }
            // End:0xBA
            else
            {
                // End:0xBA
                if(SpeedLost != TurboBoostSpeedAdd)
                {
                    KarmaParams(KParams).KMaxSpeed += (SpeedLost - TurboBoostSpeedAdd);
                    SpeedLost = 0.0;
                }
            }
            // End:0xD8
            if(TurboBoostRechargeDelay > 0.0)
            {
                TurboBoostRechargeDelay -= DeltaTime;
            }
            // End:0xF8
            else
            {
                TurboBoostMeter = FMin(0.9999990, TurboBoostMeter + (DeltaTime / TurboBoostRechargeRate));
            }
        }
    }
    // End:0x28E
    else
    {
        // End:0x166
        if(Role == ROLE_Authority)
        {
            // End:0x11C
            if(TurboBoostRechargeDelay > 0.0)
            {
                return;
            }
            TempVector = vector(Rotation);
            TempVector.Z = 0.0;
            KAddImpulse((TempVector * TurboBoostTickPush) * DeltaTime, Location + vect(0.0, 0.0, -25.0));
        }
        // End:0x194
        if(TurboBoostTickInterval > 0.0)
        {
            // End:0x191
            if(Role == ROLE_Authority)
            {
                TurboBoostTickInterval -= DeltaTime;
            }
        }
        // End:0x1E7
        else
        {
            // End:0x1DF
            if(Role == ROLE_Authority)
            {
                TurboBoostTickInterval += default.TurboBoostTickInterval;
                HurtRadius(TurboBoostDamage, TurboBoostDamageRadius, class'DamTypeLancerTurboShockwave', TurboBoostDamageMomentum, Location + (vector(Rotation) * 150.0));
            }
            UnresolvedNativeFunction_97(class'LancerShockwaveEffect');
        }
        // End:0x215
        if(FlameTickInterval > 0.0)
        {
            // End:0x212
            if(Role == ROLE_Authority)
            {
                FlameTickInterval -= DeltaTime;
            }
        }
        // End:0x256
        else
        {
            // End:0x231
            if(Role == ROLE_Authority)
            {
                FlameTickInterval += default.FlameTickInterval;
            }
            LFP = UnresolvedNativeFunction_97(class'LancerFlameProjectile', self,, Location + (vector(Rotation) * -100.0));
        }
        // End:0x28E
        if(Role == ROLE_Authority)
        {
            TurboBoostMeter -= (DeltaTime / TurboBoostConsumptionRate);
            // End:0x28E
            if(TurboBoostMeter <= 0.0)
            {
                EndBoost();
            }
        }
    }
    //return;
}

simulated function float ChargeBar()
{
    return FMin(0.9999990, TurboBoostMeter);
    //return;
}

simulated function DrawHUD(Canvas Canvas)
{
    local float XL, YL, PosY;
    local ONSHUDOnslaught H;
    local PlayerController PC;
    local string CurrentWeaponString, CoPilotLabel;
    local float tileScaleX, tileScaleY, barOrgX, barOrgY, barSizeX, barSizeY,
	    BarLevel;

    PC = PlayerController(Owner);
    // End:0x1D
    if(PC == none)
    {
        return;
    }
    H = ONSHUDOnslaught(PC.myHUD);
    // End:0x43
    if(H == none)
    {
        return;
    }
    tileScaleX = float(Canvas.SizeX) / 640.0;
    tileScaleY = float(Canvas.SizeY) / 480.0;
    barOrgX = RechargeOrigin.X * tileScaleX;
    barOrgY = RechargeOrigin.Y * tileScaleY;
    barSizeX = RechargeSize.X * tileScaleX;
    barSizeY = RechargeSize.Y * tileScaleY;
    BarLevel = MineMeter;
    CurrentWeaponString = string(MineCount);
    // End:0x139
    if(BarLevel > 0.50)
    {
        Canvas.DrawColor.R = byte(FMin((255.0 * float(2)) * (1.0 - BarLevel), 255.0));
    }
    // End:0x172
    else
    {
        Canvas.DrawColor.R = byte(255);
        Canvas.DrawColor.G = byte(float(255) * BarLevel);
    }
    Canvas.DrawColor.B = 0;
    Canvas.DrawColor.A = 64;
    Canvas.Style = 5;
    Canvas.SetPos(barOrgX, barOrgY);
    Canvas.UnresolvedNativeFunction_97(texture'WhiteTexture', barSizeX * BarLevel, barSizeY, 0.0, 0.0, float(texture'WhiteTexture'.USize), float(texture'WhiteTexture'.VSize) * BarLevel);
    Canvas.Font = H.GetMediumFontFor(Canvas);
    Canvas.UnresolvedNativeFunction_97(CurrentWeaponString, XL, YL);
    PosY = Canvas.ClipY * 0.820;
    Canvas.SetPos((Canvas.ClipX - XL) - float(5), PosY);
    Canvas.SetDrawColor(byte(255), byte(255), byte(255), 64);
    Canvas.UnresolvedNativeFunction_97(CurrentWeaponString);
    CoPilotLabel = "Tire Mines";
    Canvas.Font = H.GetConsoleFont(Canvas);
    Canvas.UnresolvedNativeFunction_97(CoPilotLabel, XL, YL);
    Canvas.SetPos((Canvas.ClipX - XL) - float(5), (PosY - float(5)) - YL);
    Canvas.SetDrawColor(160, 160, 160, 64);
    Canvas.UnresolvedNativeFunction_97(CoPilotLabel);
    //return;
}
*/

defaultproperties
{
     BikeJumpForce=1800.000000
     JumpDuration=0.220000
     JumpForceMag=25.000000
     JumpDelay=2.000000
     RedSkinB=Texture'BattleBike_Tex.Bike78SkinA'
     BlueSkinB=Texture'BattleBike_Tex.Bike78SkinABlue'
     HeadlightOffset=(X=58.000000,Z=34.000000)
     RechargeOrigin=(X=635.000000,Y=415.000000)
     RechargeSize=(X=-75.000000,Y=-2.000000)
     MultiSpawnDelay=3.000000
     UprightStiffness=29.000000
     UprightDamping=29.000000
     WheelSoftness=0.015000
     WheelPenScale=1.000000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=0.900000
     WheelLatFrictionScale=1.350000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=15.000000
     WheelSuspensionOffset=-3.000000
     WheelSuspensionMaxRenderTravel=15.000000
     FTScale=0.030000
     ChassisTorqueScale=0.100000
     MinBrakeFriction=1.500000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=1000000000.000000,OutVal=11.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2800.000000)))
     GearRatios(0)=-0.400000
     GearRatios(1)=0.600000
     GearRatios(2)=0.900000
     GearRatios(3)=1.400000
     GearRatios(4)=1.700000
     TransRatio=0.200000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=200.000000
     SteerSpeed=75.000000
     TurnDamping=150.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.150000
     IdleRPM=500.000000
     EngineRPMSoundRange=9000.000000
     DaredevilThreshInAirSpin=180.000000
     DaredevilThreshInAirTime=5.000000
     DaredevilThreshInAirDistance=60.000000
     bDoStuntInfo=True
     bAllowAirControl=True
     bAllowBigWheels=True
     JumpSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeJump05'
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=50.000000
     AirRollDamping=35.000000
     MinAirControlDamping=0.200000
     RedSkin=Texture'BattleBike_Tex.Bike78SkinB'
     BlueSkin=Texture'BattleBike_Tex.Bike78SkinBBlue'
     IdleSound=Sound'BattleBike_Snds.BikeEngine1'
     StartUpSound=Sound'BattleBike_Snds.BikeStart'
     ShutDownSound=Sound'BattleBike_Snds.Bikeoff'
     StartUpForce="RVStartUp"
     DestroyedVehicleMesh=StaticMesh'BattleBikes_ST.FragedSpecialDesST'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'W_Bike.BikeVehDeathRVEmitter'
     DisintegrationHealth=-25.000000
     DestructionLinearMomentum=(Min=200000.000000,Max=300000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectOffset=(Z=10.000000)
     ImpactDamageMult=0.100000
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=100.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVprojector'
     HeadlightProjectorOffset=(X=60.000000,Z=34.000000)
     HeadlightProjectorRotation=(Pitch=-1000)
     HeadlightProjectorScale=0.300000
     Begin Object Class=SVehicleWheel Name=FWheel
         SteerType=VST_Steered
         BoneName="FrontWheel"
         BoneRollAxis=AXIS_Y
         WheelRadius=20.000000
         SupportBoneName="FrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'W_Bike.Bike.FWheel'

     Begin Object Class=SVehicleWheel Name=RWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RearWheel"
         BoneRollAxis=AXIS_Y
         WheelRadius=20.000000
         SupportBoneName="RearStrut"
     End Object
     Wheels(1)=SVehicleWheel'W_Bike.Bike.RWheel'

     VehicleMass=2.500000
     bDrawDriverInTP=True
     bCanDoTrickJumps=True
     bDrawMeshInFP=True
     bHasHandbrake=True
     bSeparateTurretFocus=True
     EjectMomentum=500.000000
     DrivePos=(X=23.000000,Z=52.000000)
     DriveRot=(Pitch=-14000)
     EntryRadius=250.000000
     FPCamPos=(X=20.000000,Z=50.000000)
     TPCamDistance=375.000000
     TPCamLookat=(X=20.000000,Z=50.000000)
     TPCamWorldOffset=(Z=100.000000)
     ShadowCullDistance=2000.000000
     DriverDamageMult=0.800000
     VehiclePositionString="on a Bike"
     VehicleNameString="Bike"
     MaxDesireability=0.600000
     ObjectiveGetOutDist=1500.000000
     WaterDamage=20.000000
     GroundSpeed=2000.000000
     bReplicateAnimations=True
     Mesh=SkeletalMesh'BattleBikes_Anim.FragEdSpecMesh'
     DrawScale=0.600000
     SoundVolume=180
     CollisionRadius=100.000000
     CollisionHeight=40.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(X=-1.050000,Z=-0.902000)
         KLinearDamping=0.050000
         KAngularDamping=1.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=1.000000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'W_Bike.Bike.KParams0'

}
