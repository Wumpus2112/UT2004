//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SentryX extends ASVehicle_Sentinel_Floor;

var float secondsToLive;
var bool isInit;

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    log("SentryX TakeDamage");
    SetPhysics(PHYS_none);

	super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

}




DefaultProperties
{
    Health=1000
    HealthMax=1000

    AutoTurretControllerClass=class'W_Sentry.SentryController'
    SightRadius=+25000.0

    //Physics=PHYS_None
    //Physics=PHYS_Rotating
    Physics=PHYS_Falling

    bSimulateGravity=True
    bStationary=False
    MaxFallSpeed=100.000000

    secondsToLive = 10.0



    //bIgnoreForces=True


    /********************************************/


    bTeamLocked=True

     EjectMomentum=2500.000000

     AccelRate=2000.000000

     RotationInertia=20.000000
     CamRotationInertia=10.330000


     CenterSpringForce="SpringSpaceFighter"
     CenterSpringRangePitch=0
     CenterSpringRangeRoll=0
     DriverDamageMult=0.000000
     bCanFly=True
     bCanStrafe=True
     bDirectHitWall=True
     bServerMoveSetPawnRot=False

     LandMovementState="PlayerSpaceFlying"
     MaxRotation=40.849998


     RotationRate=(Pitch=32768,Yaw=32768,Roll=32768)
     ForceType=FT_DragAlong
     ForceRadius=100.000000
     ForceScale=5.000000

    FPCamPos=(X=15.00,Y=0.00,Z=20.00)

    bCanCarryFlag=false;

    AmbientGlow=86
    SoundRadius=100.00
    TransientSoundVolume=1.00
    TransientSoundRadius=784.00

//    CollisionHeight=68.00
//    CollisionRadius=120.00
}
