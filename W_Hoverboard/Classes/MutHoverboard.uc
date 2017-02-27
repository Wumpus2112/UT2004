//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutHoverboard extends Mutator;

function ModifyPlayer (Pawn Other)
{
  Other.CreateInventory("WumpusHoverboard.HoverboardLauncher");
  Super.ModifyPlayer(Other);
  if ( NextMutator != None )
  {
    NextMutator.ModifyPlayer(Other);
  }
}

function bool AlwaysKeep (Actor Other)
{
  if ( Other.IsA('HoverboardLauncher') )
  {
    return True;
  }
  if ( NextMutator != None )
  {
    return NextMutator.AlwaysKeep(Other);
  }
  return False;
}

defaultproperties
{
    GroupName="HoverboardLauncher"
    FriendlyName="Wumpus Hoverboard Launcher"
    Description="Hoverboard Launcher"

    bAddToServerPackages=True
    bAlwaysRelevant=True
    RemoteRole=2
}