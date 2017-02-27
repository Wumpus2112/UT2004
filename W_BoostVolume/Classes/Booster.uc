//=============================================================================
// Booster
//=============================================================================
class Booster extends Info;

/******/
var() float BoostForce;
var float gravity;
var() int count;

   // event Tick(float DeltaTime)
   event Timer()
    {
        local vector Force;
        local float DeltaTime;
        local ONSWheeledCraft wheeledVehicle;

        DeltaTime = 0.1;

        //wheeledVehicle = (ONSWheeledCraft)Owner;

     /*

        Force = vector(Owner.Rotation); // get direction of vehicle
        Force = Owner.Velocity; // get direction of vehicle
		Force += Normal(Force) * (BoostForce*DeltaTime); // apply force in that direction
          log("timer");

          if(Owner != none){
              Owner.KAddAngularImpulse(Force);
          }else{
              Destroy();
          }
          */
           /*
          if(count == 0){
              gravity = wheeledVehicle.Act Params(KParams).KActorGravScale;
          }

          KarmaParams(KParams).KActorGravScale = gravity/4;

          if(count < 200){
              KarmaParams(KParams).KActorGravScale = gravity;
              destroy();
          }
             */
          count++;

}





defaultproperties
{
     LifeSpan=2.000000
     BoostForce=0.02

     RemoteRole=ROLE_None
    bAlwaysTick=true
}
