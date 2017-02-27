//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutWTranslocator extends Mutator
  config(WTranslocatorConfig)
  HideCategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var config bool bDisableTrails;
var config bool bUnlimitedAmmo;
var config int TossForce;

var bool bShowChargingBar;
var localized string TrailsDisplayText;
var localized string TrailsDescText;
var localized string AmmoDisplayText;
var localized string AmmoDescText;
var localized string TossDisplayText;
var localized string TossDescText;

static function FillPlayInfo (PlayInfo PlayInfo)
{
  Super.FillPlayInfo(PlayInfo);
  PlayInfo.AddSetting("W Translocator","bDisableTrails",default.TrailsDisplayText,1,1,"Check");
  PlayInfo.AddSetting("W Translocator","bUnlimitedAmmo",default.AmmoDisplayText,1,1,"Check");
  PlayInfo.AddSetting("W Translocator","TossForce",default.TossDisplayText,1,1,"Text","4;1200:2500");
}

static event string GetDescriptionText (string PropName)
{
  switch (PropName)
  {
    case "bDisableTrails":
    return Default.TrailsDescText;
    case "bUnlimitedAmmo":
    return Default.AmmoDescText;
    case "TossForce":
    return Default.TossDescText;
    default:
  }
  return Super.GetDescriptionText(PropName);
}

simulated function PreBeginPlay ()
{
  if ( bUnlimitedAmmo == False )
  {
    Default.bShowChargingBar = True;
  }
  Super.PreBeginPlay();
}

simulated function PostBeginPlay ()
{
//  local GameRules P;

  DeathMatch(Level.Game).bAllowTrans = True;
  class'WTransLauncher'.Default.bShowChargingBar = Default.bShowChargingBar;
//  P = Spawn(Class'TFRules');
//  if ( Level.Game.GameRulesModifiers == None )
//  {
//    Level.Game.GameRulesModifiers = P;
//  } else {
//    Level.Game.GameRulesModifiers.AddGameRules(P);
//  }
  Super.PostBeginPlay();
}

simulated function Tick (float Delta)
{
  local xPawn P;

  Super.Tick(Delta);
  foreach DynamicActors(Class'xPawn',P)
  {
    if ( P.IsInState('Dying') && ((P.HitDamageType == Class'Gibbed') || (P.HitDamageType == Class'DamTypeTelefragged')) )
    {
      P.ChunkUp(P.Rotation,1.0);
    }
  }
}

function ModifyPlayer (Pawn Other)
{
  Other.GiveWeapon("W_Sniper.WTranslauncher");
  Super.ModifyPlayer(Other);
  if ( NextMutator != None )
  {
    NextMutator.ModifyPlayer(Other);
  }
}

function string GetInventoryClassOverride (string strTLClass)
{
  if ( strTLClass == "XWeapons.TransLauncher" )
  {
    strTLClass = "W_Sniper.WTranslauncher";
  }
  if ( strTLClass == "OLTeamGames.OLTeamsTranslauncher" )
  {
    strTLClass = "W_Sniper.WTranslauncher";
  }
  if ( NextMutator != None )
  {
    return NextMutator.GetInventoryClassOverride(strTLClass);
  }
  return strTLClass;
}

function bool CheckReplacement (Actor Other, out byte bSuperRelevant)
{
  local int i;
  local WeaponLocker L;

  bSuperRelevant = 0;
  if ( xWeaponBase(Other) != None )
  {
    if ( xWeaponBase(Other).WeaponType == Class'Translauncher' )
    {
      xWeaponBase(Other).WeaponType = Class'WTranslauncher';
    } else {
      return True;
    }
  } else {
    if ( WeaponPickup(Other) != None )
    {
      if ( string(Other.Class) == "XWeapons.Transpickup" )
      {
        ReplaceWith(Other,"W_Sniper.WTranslauncher");
      } else {
        return True;
      }
    } else {
      if ( WeaponLocker(Other) != None )
      {
        L = WeaponLocker(Other);
        i = 0;
        if ( i < L.Weapons.Length )
        {
          if ( L.Weapons[i].WeaponClass == Class'Translauncher' )
          {
            L.Weapons[i].WeaponClass = Class'WTranslauncher';
          }
          i++;
//          goto JL00E9;
        }
        return True;
      } else {
        return True;
      }
    }
  }
  return False;
}

function bool AlwaysKeep (Actor Other)
{
  if ( Other.IsA('WTranslauncher') )
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
     bDisableTrails=True
     bUnlimitedAmmo=True
     TossForce=2500
     TrailsDisplayText="Disable Trails"
     TrailsDescText="Disables the in-flight tracer that trails the transbeacon"
     AmmoDisplayText="Unlimited Ammo"
     AmmoDescText="Unlimited Trans Ammo"
     TossDisplayText="TossForce"
     TossDescText="Adjusts the Transbeacon Velocity (The Stock Translocator uses 1200 TossForce)"
     bAddToServerPackages=True
     GroupName="TransLauncher"
     FriendlyName="W Translocator"
     Description="W Trans"
     bAlwaysRelevant=True
}
