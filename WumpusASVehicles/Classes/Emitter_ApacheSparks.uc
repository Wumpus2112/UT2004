//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Emitter_ApacheSparks extends Emitter
  Placeable;

simulated function StartSparks (bool bTailGone)
{
  if (  !bTailGone )
  {
    Emitters[0].Disabled = True;
    Emitters[1].Disabled = True;
  } else {
    Emitters[0].Disabled = False;
    Emitters[1].Disabled = False;
  }
}

defaultproperties
{
    Emitters=

    AutoDestroy=True

    CullDistance=12000.00

    bNoDelete=False

    AmbientGlow=140

    bHardAttach=True

}
