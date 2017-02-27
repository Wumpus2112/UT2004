//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutSuperWeaponReplacer extends Mutator
     config (W_SuperWeaponReplacer);

var() config class<Weapon> WeaponType[8];

function PostBeginPlay()
{
    SaveConfig();
    Super.PostBeginPlay();
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
    local bool isSuper;
    local bool isReplaced;

    bSuperRelevant = 0;
    if ( xWeaponBase(Other) != None ){

        isSuper = xWeaponBase(Other).WeaponType.default.InventoryGroup == 0 ;

        if(isSuper){
            xWeaponBase(Other).WeaponType = none;
            isReplaced = ReplaceWithRotator( Other, "W_BBRedeemer.WildcardRedeemerPickupBase");
            return false;
        }else{
            return true;
        }
    }

    return true;
}

function bool ReplaceWithRotator(Actor OldOther, string aClassName)
{
	local Actor A;
	local xPickupBase xNewBase;
	local xPickupBase xOldBase;
	local class<Actor> aClass;

	xOldBase = xPickupBase(OldOther);

	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));

	A = Spawn(aClass,,,xOldBase.Location, xOldBase.Rotation);

    xNewBase = xPickupBase(A);

    AddWeaponTypes(xNewBase);

	A.SetLocation(A.Location);

	A.event = xOldBase.event;

    A.tag = xOldBase.tag;

    xOldBase.MyMarker = None;

    xOldBase.Destroy();

	return true;
}

function AddWeaponTypes(xPickupBase xNewBase){
    local WildcardRedeemerPickupBase wPickupBase;
    local int i;

    wPickupBase = WildcardRedeemerPickupBase(xNewBase);
    if(wPickupBase != none){
         for(i=0;i<8;i++){
             if(WeaponType[i] != none){
                 wPickupBase.AddWeaponType(WeaponType[i]);
             }
         }
    }

}

defaultproperties
{
     WeaponType(0)=Class'W_BBRedeemer.BBRedeemer'
     WeaponType(1)=Class'W_EMPRedeemer.EMPRedeemer'
     WeaponType(2)=Class'EHWeapons.EHRedeemerII'
     WeaponType(3)=Class'StormCaster.StormCaster'
     WeaponType(4)=Class'ChaosUT.Vortex'
     bAddToServerPackages=True
     GroupName="SuperWeapon"
     FriendlyName="W_SuperWeaponReplacer"
     Description="Replace all super weapons in map with Redeemer Rotator."
}
