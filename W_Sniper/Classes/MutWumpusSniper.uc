class MutWumpusSniper extends Mutator
     config;


var() config string ArenaWeaponClassName;
var bool bInitialized;
var class<Weapon> ArenaWeaponClass;
var string ArenaWeaponPickupClassName;
var string ArenaAmmoPickupClassName;

var config bool bDisableTrails;
var config bool bUnlimitedAmmo;
var config int TossForce;

var bool bShowChargingBar;

simulated function BeginPlay()
{
	local WeaponLocker L;

	foreach AllActors(class'WeaponLocker', L)
		L.GotoState('Disabled');

	Super.BeginPlay();
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
  DeathMatch(Level.Game).bAllowTrans = True;
  class'WTransLauncher'.Default.bShowChargingBar = Default.bShowChargingBar;
  Super.PostBeginPlay();
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



function Initialize()
{
    local int FireMode;

    bInitialized = true;
    DefaultWeaponName = ArenaWeaponClassName;
    ArenaWeaponClass = class<Weapon>(DynamicLoadObject(ArenaWeaponClassName,class'class'));
    DefaultWeapon = ArenaWeaponClass;
    ArenaWeaponPickupClassName = string(ArenaWeaponClass.default.PickupClass);
    for( FireMode = 0; FireMode<2; FireMode++ )
    {
        if( (ArenaWeaponClass.default.FireModeClass[FireMode] != None)
        && (ArenaWeaponClass.default.FireModeClass[FireMode].default.AmmoClass != None)
        && (ArenaWeaponClass.default.FireModeClass[FireMode].default.AmmoClass.default.PickupClass != None) )
        {
            ArenaAmmoPickupClassName = string(ArenaWeaponClass.default.FireModeClass[FireMode].default.AmmoClass.default.PickupClass);
            break;
        }
    }
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
    local WumpusSniperWeaponLocker L;
    local int i;

    if ( !bInitialized )
        Initialize();

//    log("Replacing:"@Other);

    bSuperRelevant = 0;

    if ( WeaponLocker(Other) != None && WumpusSniperWeaponLocker(Other) == none)
        ReplaceWith( Other, "WumpusSniper.WumpusSniperWeaponLocker");

    if ( WumpusSniperWeaponLocker(Other) != None ){
      L = WumpusSniperWeaponLocker(Other);
      for (i = 0; i < L.Weapons.Length; i++){
            L.Weapons[i].WeaponClass = ArenaWeaponClass;
            L.Weapons[i].ExtraAmmo = 25;
      }
      return true;
   }

    if ( xWeaponBase(Other) != None )
    {
//        log("1");
        // Replace Weapon Base
//        xWeaponBase(Other).WeaponType = ArenaWeaponClass;
    }
    else if ( (Weapon(Other) != None) && (Other.class != ArenaWeaponClass) )
    {
//            log("2");
        if(!IsStandardWeapon(Other)) return true;

        // replaces player weapons
        if ( Weapon(Other).bNoInstagibReplace )
        {
//            log("3");

            bSuperRelevant = 0;
            return true;
        }
//            log("4");
        return false;
    }
//    else if ( (WeaponPickup(Other) != None) /* && (string(Other.class) != ArenaWeaponPickupClassName) */)
    else if(WeaponPickup(Other) != None)
    {
//            log("5");

        // Weapon Replace
        if(!IsStandardWeaponPickup(Other)) return true;
//        if(RedeemerPickup(Other) != none) return true;
        ReplaceWith( Other, ArenaAmmoPickupClassName); // Puts ammo on weapon spot
    }
    else if ( (Ammo(Other) != None) && (string(Other.Class) != ArenaAmmoPickupClassName) )
    {
//            log("6");

        // Ammo replace
        ReplaceWith( Other, ArenaAmmoPickupClassName);
    }
    else
    {
//            log("7");
        // objects you don't want to replace
        if ( Other.IsA('WeaponLocker') ){
//            log("8");
            Other.GotoState('Disabled');
        }
//            log("9");

        return true;
    }
    // something was replaced
//    log("10");

    return false;
}

function bool IsStandardWeapon(Actor Other){
    return(
        (AssaultRifle(Other) != none) ||
        (BioRifle(Other) != none) ||
        (FlakCannon(Other) != none) ||
        (LinkGun(Other) != none) ||
        (Minigun(Other) != none) ||

        (ClassicSniperRifle(Other) != none) ||
        (SniperRifle(Other) != none) ||
        (ONSAVRiL(Other) != none) ||
        (ONSGrenadeLauncher(Other) != none) ||
        (ONSMineLayer(Other) != none) ||

        (RocketLauncher(Other) != none) ||
//        (ShieldGun(Other) != none) ||
        (ShockRifle(Other) != none) ||
//        (Trans(Other) != none) ||
        (SuperShockRifle(Other) != none)
        );
}
function bool IsStandardWeaponPickup(Actor Other){
    return(
        (AssaultRiflePickup(Other) != none) ||
        (BioRiflePickup(Other) != none) ||
        (FlakCannonPickup(Other) != none) ||
        (LinkGunPickup(Other) != none) ||
        (MinigunPickup(Other) != none) ||

        (ClassicSniperRiflePickup(Other) != none) ||
        (SniperRiflePickup(Other) != none) ||
        (ONSAVRiLPickup(Other) != none) ||
        (ONSGrenadePickup(Other) != none) ||
        (ONSMineLayerPickup(Other) != none) ||

        (RocketLauncherPickup(Other) != none) ||
        (ShieldGunPickup(Other) != none) ||
        (ShockRiflePickup(Other) != none) ||
//        (TransPickup(Other) != none) ||
        (SuperShockRiflePickup(Other) != none)
        );
}

function bool AlwaysKeep (Actor Other)
{
  if ( Other.IsA('WTranslauncher') ||  Other.IsA('ShieldGun'))
  {
    return True;
  }
  if ( NextMutator != None )
  {
    return NextMutator.AlwaysKeep(Other);
  }
  return False;
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

defaultproperties
{
     ArenaWeaponClassName="W_Sniper.WumpusSniperRifle"
     GroupName="Wumpus Group"
     FriendlyName="Wumpus Sniper"
     Description="Replace weapons and ammo with Sniper Rifle in map."

     bDisableTrails=True
     bUnlimitedAmmo=True
     TossForce=2500

     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}






/*
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
      */





