//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SuperTC extends ONSGenericSD;

var() float MaxPitchSpeed;
var bool bClientDoNitrous;
var float DoNitrousTime;
var float NitrousForce;
var int NitrousRemaining;
var() sound NitrousSound;
var float NitrousRechargeTime;
var float NitrousRechargeCounter;
var float NitrousCountdown;

replication
{
  unreliable if ( bNetDirty && (Role == 4) )
    bClientDoNitrous,NitrousRemaining;
}

function ChooseFireAt (Actor A)
{
  if ( (Pawn(A) != None) && (Vehicle(A) == None) && (VSize(A.Location - Location) < 1500) && Controller.LineOfSightTo(A) )
  {
    if (  !bWeaponisAltFiring )
    {
      AltFire(0.0);
    }
  } else {
    if ( bWeaponisAltFiring )
    {
      VehicleCeaseFire(True);
    }
  }
  Fire(0.0);
}

simulated function PostNetBeginPlay ()
{
  super.PostNetBeginPlay();
  if ( Role == 4 )
  {
    PitchUpLimit = default.PitchUpLimit;
    PitchDownLimit = Default.PitchDownLimit;
  }
}

function VehicleFire (bool bWasAltFire)
{
  if ( bWasAltFire )
  {
    Nitrous();
  } else {
    Super.VehicleFire(bWasAltFire);
  }
}

simulated event KApplyForce (out Vector Force, out Vector Torque)
{
  local int i;
  local float avgLoad;

  super.KApplyForce(Force,Torque);
  if ( bClientDoNitrous && bVehicleOnGround )
  {
    avgLoad = 0.0;

    for(i = 0; i < Wheels.Length ; i++)
    {
      avgLoad += Wheels[i].TireLoad;
      i++;
    }
    avgLoad = avgLoad / Wheels.Length;
    avgLoad = FMin(avgLoad,20.0);
    avgLoad = avgLoad / 20.0;
    Force = Force + vector(Rotation);
    Force = Force + Normal(Force) * NitrousForce * avgLoad;
  }

}

function Nitrous ()
{
  if ( (NitrousRemaining > 0) &&  !bClientDoNitrous )
  {
    NitrousRechargeCounter = 0.0;
    PlaySound(NitrousSound,SLOT_Misc,1.0);
    bClientDoNitrous = True;
    NitrousRemaining--;
    NitrousCountdown = DoNitrousTime;
  }

}

simulated event Tick (float DeltaTime)
{
  Super.Tick(DeltaTime);

    if ( bClientDoNitrous )
    {
        NitrousCountdown = NitrousCountdown - DeltaTime;
        if(NitrousCountdown < 0){
            bClientDoNitrous = false;
        }
    }

  if ( Role == 4 )
  {
    NitrousRechargeCounter += DeltaTime;
    if ( NitrousRechargeCounter > NitrousRechargeTime )
    {
      if ( NitrousRemaining < 2 )
      {
        NitrousRemaining++;
      }
      NitrousRechargeCounter = 0.0;
    }
  }
}

function int LimitPitch (int Pitch)
{
  return Super(Pawn).LimitPitch(Pitch);
}

DefaultProperties
{
    GroundSpeed=2000

    TorqueCurve=(Points=((InVal=0,OutVal=9.0),(InVal=200,OutVal=10.0),(InVal=1500,OutVal=11.0),(InVal=2800,OutVal=0.0)))

// SuperTC
//    MaxSteerAngleCurve=(Points=((InVal=0,OutVal=25.0),(InVal=1500.0,OutVal=11.0),(InVal=1000000000.0,OutVal=11.0)))
//    SteerSpeed=160

    MaxSteerAngleCurve=(Points=((InVal=0,OutVal=25.0),(InVal=1500.0,OutVal=15.0),(InVal=1000000000.0,OutVal=15.0)))
    SteerSpeed=210

// Hellbender
//    MaxSteerAngleCurve=(Points=((InVal=0,OutVal=25.0),(InVal=1500.0,OutVal=8.0),(InVal=1000000000.0,OutVal=8.0)))
//    SteerSpeed=110

// Scorpion
//    MaxSteerAngleCurve=(Points=((InVal=0,OutVal=25.0),(InVal=1500.0,OutVal=11.0),(InVal=1000000000.0,OutVal=11.0)))
//    SteerSpeed=160

    bClientDoNitrous=false
    DoNitrousTime=3.00
    NitrousRechargeTime=8.00
    NitrousForce=200.00
    NitrousRemaining=2
    NitrousSound=sound'GSounds.Tumbler.TumblerThruster'
}
