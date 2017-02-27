class MutWumpusConcussion extends Mutator
     config;

var() config string ArenaWeaponClassName;
var bool bInitialized;
var class<Weapon> ArenaWeaponClass;
var string ArenaWeaponPickupClassName;
var string ArenaAmmoPickupClassName;
var localized string ArenaDisplayText, ArenaDescText;

simulated function BeginPlay()
{
    super.BeginPlay();
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
    local WumpusConcussionWeaponLocker L;
    local int i;

    if ( !bInitialized )
        Initialize();

//    log("Replacing:"@Other);

    bSuperRelevant = 0;

    if ( WeaponLocker(Other) != None && WumpusConcussionWeaponLocker(Other) == none)
        ReplaceWith( Other, "WumpusConcussion.WumpusConcussionWeaponLocker");

    if ( WumpusConcussionWeaponLocker(Other) != None ){
      L = WumpusConcussionWeaponLocker(Other);
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


static function FillPlayInfo(PlayInfo PlayInfo)
{
    local array<CacheManager.WeaponRecord> Recs;
    local string WeaponOptions;
    local int i;

    Super.FillPlayInfo(PlayInfo);

    class'CacheManager'.static.GetWeaponList(Recs);
    for (i = 0; i < Recs.Length; i++)
    {
        if (WeaponOptions != "")
            WeaponOptions $= ";";

        WeaponOptions $= Recs[i].ClassName $ ";" $ Recs[i].FriendlyName;
    }

    PlayInfo.AddSetting(default.RulesGroup, "ArenaWeaponClassName", default.ArenaDisplayText, 0, 1, "Select", WeaponOptions);
}

static event string GetDescriptionText(string PropName)
{
    if (PropName == "ArenaWeaponClassName")
        return default.ArenaDescText;

    return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     ArenaWeaponClassName="WumpusConcussion.WumpusConcussionRifle"
     ArenaDisplayText="Arena Weapon"
     ArenaDescText="Determines which weapon will be used in the arena match"
     GroupName="Wumpus Group"
     FriendlyName="Concussion Rifle"
     Description="Replace weapons and ammo with Concussion Rifle in map."
     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
