//=============================================================================
// xWeaponBase
//=============================================================================
class xWeaponRotatingBase extends xPickUpBase
    placeable;

#exec OBJ LOAD FILE=2k4ChargerMeshes.usx

//var() class<Weapon> WeaponType;
var() class<Weapon> WeaponType[8];


function bool CheckForErrors()
{
	if ( (WeaponType[0] == None) || WeaponType[0].static.ShouldBeHidden() )
	{
		log(self$" ILLEGAL WEAPONTYPE "$Weapontype[0]);
		return true;
	}
	return Super.CheckForErrors();
}

function byte GetInventoryGroup()
{
	if (WeaponType[0] != None)
		return WeaponType[0].Default.InventoryGroup;
	return 999;
}

simulated function PostBeginPlay()
{
	if (WeaponType[0] != None)
	{
		PowerUp = WeaponType[0].default.PickupClass;
		if ( WeaponType[0].Default.InventoryGroup == 0 )
			bDelayedSpawn = true;
	}
    Super.PostBeginPlay();
	SetLocation(Location + vect(0,0,-2)); // adjust because reduced drawscale
}

defaultproperties
{
     SpiralEmitter=Class'XEffects.Spiral'
     NewStaticMesh=StaticMesh'2k4ChargerMeshes.ChargerMeshes.WeaponChargerMesh-DS'
     NewPrePivot=(Z=3.700000)
     NewDrawScale=0.500000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_rc.WildcardChargerMesh'
     Texture=None
     DrawScale=0.500000
     Skins(0)=Texture'XGameTextures.WildcardChargerTex'
     Skins(1)=Texture'XGameTextures.WildcardChargerTex'
     CollisionRadius=60.000000
     CollisionHeight=3.000000
}
