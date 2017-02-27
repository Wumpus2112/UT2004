//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Emitter_ApacheExhaust extends Emitter
  Placeable;

simulated function SetThrust (float Amount)
{
  Emitters[0].StartSizeRange.X.Min = -0.1 - Amount * 0.31;
  Emitters[0].StartSizeRange.X.Max = -0.2 - Amount * 0.81;
  Emitters[1].StartVelocityRange.X.Min = 150.0 + Amount * 250;
  Emitters[1].StartVelocityRange.X.Max = Emitters[1].StartVelocityRange.X.Min;
  Emitters[1].ParticlesPerSecond = 30.0 + Amount * 70;
  Emitters[1].InitialParticlesPerSecond = 30.0 + Amount * 70;
}

simulated function SetThrustEnabled (bool bDoThrust)
{
  if ( bDoThrust )
  {
    Emitters[0].Disabled = False;
    Emitters[1].Disabled = False;
  } else {
    Emitters[0].Disabled = True;
    Emitters[1].Disabled = True;
  }
}

defaultproperties
{
     AutoDestroy=True
     CullDistance=12000.000000
     bNoDelete=False
     AmbientGlow=140
     bHardAttach=True
}
