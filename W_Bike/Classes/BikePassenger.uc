//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BikePassenger extends ONSWeaponPawn;

var Rotator ArmDriveL;
var Rotator ArmDriveR;
var Rotator NeckDrive;
var Rotator ThighDriveL;
var Rotator ThighDriveR;
var Rotator CalfDriveL;
var Rotator CalfDriveR;

simulated function AttachDriver(Pawn P)
{
    super.AttachDriver(P);
    NeckDrive.Yaw = -10000;
    P.SetBoneRotation('Bip01 Head', NeckDrive);
    ArmDriveL.Yaw = -5000;
    ArmDriveL.Pitch = -2500;
    P.SetBoneRotation('Bip01 L UpperArm', ArmDriveL);
    ArmDriveR.Yaw = -5000;
    ArmDriveR.Pitch = 2500;
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
    //return;
}

function KDriverEnter(Pawn P)
{
    super.KDriverEnter(P);
    // End:0x69
    if(Driver != none)
    {
        Driver.NextWeapon();
        Driver.PrevWeapon();
        // End:0x69
        if((Controller != none) && Driver.Controller == none)
        {
            Driver.Controller = Controller;
        }
    }
    //return;
}

function bool KDriverLeave(bool bForceLeave)
{
    local bool bResult;

    VehicleCeaseFire(false);
    VehicleCeaseFire(true);
    bResult = super.KDriverLeave(bForceLeave);
    // End:0x4E
    if(bResult)
    {
        // End:0x3C
        if(Driver != none)
        {
            Driver = none;
        }
        // End:0x4E
        if(Controller != none)
        {
            Controller = none;
        }
    }
    return bResult;
    //return;
}

simulated function Tick(float DeltaTime)
{
    super(Actor).Tick(DeltaTime);
    // End:0x8A
    if(((Driver != none) && Controller != none) && PlayerReplicationInfo != none)
    {
        Driver.Controller = Controller;
        Driver.PlayerReplicationInfo = PlayerReplicationInfo;
        xPawn(Driver).Controller = Controller;
        xPawn(Driver).PlayerReplicationInfo = PlayerReplicationInfo;
    }
    //return;
}

function Fire(optional float F)
{
    // End:0x183
    if(((Driver != none) && Driver.Health > 0) && Driver.Weapon != none)
    {
        // End:0x119
        if((((Controller != none) /*&& Controller.UnresolvedNativeFunction_97('AIController')*/) && Bot(Controller).Target != none) && !Bot(Controller).LineOfSightTo(Bot(Controller).Target) || (Pawn(Bot(Controller).Target) != none) && Pawn(Bot(Controller).Target).GetTeamNum() == (GetTeamNum()))
        {
            Controller.bFire = 0;
            Driver.Weapon.ClientStopFire(0);
            return;
        }
        // End:0x156
        if((Controller != none) && Driver.Weapon.AmmoAmount(0) < 1)
        {
            Driver.PrevWeapon();
            return;
        }
        Driver.Controller = Controller;
        Driver.Weapon.ClientStartFire(0);
    }
    //return;
}

function AltFire(optional float F)
{
    // End:0x183
    if(((Driver != none) && Driver.Health > 0) && Driver.Weapon != none)
    {
        // End:0x119
        if((((Controller != none) /*&& Controller. UnresolvedNativeFunction_97('AIController')*/) && Bot(Controller).Target != none) && !Bot(Controller).LineOfSightTo(Bot(Controller).Target) || (Pawn(Bot(Controller).Target) != none) && Pawn(Bot(Controller).Target).GetTeamNum() == (GetTeamNum()))
        {
            Controller.bAltFire = 0;
            Driver.Weapon.ClientStopFire(1);
            return;
        }
        // End:0x156
        if((Controller != none) && Driver.Weapon.AmmoAmount(1) < 1)
        {
            Driver.PrevWeapon();
            return;
        }
        Driver.Controller = Controller;
        Driver.Weapon.ClientStartFire(1);
    }
    //return;
}

function VehicleCeaseFire(bool bWasAltFire)
{
    super.VehicleCeaseFire(bWasAltFire);
    // End:0x6B
    if((Driver != none) && Driver.Weapon != none)
    {
        // End:0x52
        if(bWasAltFire)
        {
            Driver.Weapon.ClientStopFire(1);
        }
        // End:0x6B
        else
        {
            Driver.Weapon.ClientStopFire(0);
        }
    }
    //return;
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
    super.ClientVehicleCeaseFire(bWasAltFire);
    // End:0x6B
    if((Driver != none) && Driver.Weapon != none)
    {
        // End:0x52
        if(bWasAltFire)
        {
            Driver.Weapon.ClientStopFire(1);
        }
        // End:0x6B
        else
        {
            Driver.Weapon.ClientStopFire(0);
        }
    }
    //return;
}

function float RefireRate()
{
    // End:0x3D
    if((Driver != none) && Driver.Weapon != none)
    {
        return Driver.Weapon.RefireRate();
    }
    // End:0x43
    else
    {
        return 0.0;
    }
    //return;
}

simulated function PrevWeapon()
{
    // End:0x1A
    if(Driver != none)
    {
        Driver.PrevWeapon();
    }
    //return;
}

simulated function NextWeapon()
{
    // End:0x1A
    if(Driver != none)
    {
        Driver.NextWeapon();
    }
    //return;
}

simulated function SwitchWeapon(byte F)
{
    // End:0x35
    if(F != byte(1))
    {
        // End:0x30
        if(Driver != none)
        {
            Driver.SwitchWeapon(F);
        }
        return;
    }
    // End:0x40
    else
    {
        super.SwitchWeapon(F);
    }
    //return;
}

simulated function Destroyed()
{
    VehicleCeaseFire(false);
    VehicleCeaseFire(true);
    // End:0x25
    if(Gun != none)
    {
        Gun.Destroy();
    }
    super.Destroyed();
    Controller = none;
    //return;
}

defaultproperties
{
    GunClass=class'BikePassAttachment'
    DrivePos=(X=10.0,Y=0.0,Z=10.0)
    DriveRot=(Pitch=-10000,Yaw=0,Roll=0)
    ExitPositions=/* Array type was not detected. */
    EntryPosition=(X=40.0,Y=50.0,Z=-100.0)
    EntryRadius=170.0
    FPCamPos=(X=0.0,Y=0.0,Z=20.0)
    TPCamDistance=500.0
    TPCamLookat=(X=-100.0,Y=0.0,Z=50.0)
    DriverDamageMult=0.40
    VehiclePositionString="On the back of a Bike"
    VehicleNameString="Bike Passenger"
}
