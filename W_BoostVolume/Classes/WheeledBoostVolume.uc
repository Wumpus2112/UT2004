//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WheeledBoostVolume extends PhysicsVolume;

var()   Array< class<Actor> >   AffectedClasses;
var()   float                   EntryAngleFactor; // Actor DOT volume direction must be greater than this
var()   float                   BoostForce;       // Karma force to be applied
var()   bool                    bBoostRelative;   // If true, boost the actor in the direction of the actor instead of the volume direction

simulated event Touch(Actor Other)
{
	Super.Touch(Other);

    log("0a");

    if (Other != None)
    {
        if(ClassIsChildOf(Other.Class,class'ONSWheeledCraft') || Other.IsA('ONSWheeledCraft')){
            log("1a");
            TryBoost(Other);
        }
    }
}


simulated event UnTouch(Actor Other)
{
	Super.UnTouch(Other);

	Gravity = Default.Gravity;
}

simulated function TryBoost(Actor Other)
{
    local float EntryAngle;

    log("2a");

    EntryAngle = Normal(Other.Velocity) dot Vector(Rotation);

    if (EntryAngle > EntryAngleFactor)
        ActivateBoost(Other);
}


simulated function ActivateBoost(Actor Other)
{
    if (bBoostRelative)
        Gravity = Default.Gravity + (BoostForce * Normal(Other.Velocity));
    else
        Gravity = Default.Gravity + (BoostForce * Vector(Rotation));
/*
    local Booster b;

        b = Spawn(class'Booster', Other); // it's responsible for killing itself
        b.SetTimer(0.1,true);



    if (bBoostRelative){
        b = Spawn(class'Booster', Other); // it's responsible for killing itself
        b.Enable('Tick');
        log("3a");

    }else{
        Spawn(class'Booster', Other); // it's responsible for killing itself
        b = Spawn(class'Booster', Other); // it's responsible for killing itself
        b.Enable('Tick');
        log("4a");
    }

 */


        /*
simulated event KApplyForce(out vector Force, out vector Torque)
{
	Super.KApplyForce(Force, Torque); // apply other forces first

	if (bBoost && bVehicleOnGround)
	{
    Force += vector(Rotation); // get direction of vehicle
		Force += Normal(Force) * BoostForce; // apply force in that direction
	}
}
          */

}

defaultproperties
{
     BoostForce=2000
     EntryAngleFactor=0.700000
     bDirectional=True
}
