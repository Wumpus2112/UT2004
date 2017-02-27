//=============================================================================
// WildcardBase
//=============================================================================
class WildcardRedeemerPickupBase extends xPickUpBase
    placeable;

var() class<Weapon> WeaponType[8];
var() bool bSequential;
var int NumClasses;
var int CurrentClass;

simulated function PostBeginPlay()
{
	local int i;

	if ( Role == ROLE_Authority )
	{
		NumClasses = 0;
		while (NumClasses < ArrayCount(WeaponType) && WeaponType[NumClasses] != None)
			NumClasses++;

		if (bSequential)
			CurrentClass = 0;
		else
			CurrentClass = Rand(NumClasses);

		PowerUp =  WeaponType[CurrentClass].default.PickupClass;
	}
	if ( Level.NetMode != NM_DedicatedServer )
	{
		for ( i=0; i< NumClasses; i++ )
			WeaponType[i].default.PickupClass.static.StaticPrecache(Level);
	}
	Super.PostBeginPlay();
	SetLocation(Location + vect(0,0,-1)); // adjust because reduced drawscale

}

function TurnOn()
{
	if (bSequential)
		CurrentClass = (CurrentClass+1)%NumClasses;
	else
		CurrentClass = Rand(NumClasses);

	PowerUp = WeaponType[CurrentClass].default.PickupClass;

	if( myPickup != None )
		myPickup = myPickup.Transmogrify(PowerUp);
}


function AddWeaponType(class<Weapon> newWeapon){
    WeaponType[NumClasses] = newWeapon;
    NumClasses++;
}

defaultproperties
{
     WeaponType(0)=Class'W_BBRedeemer.BBRedeemer'
     SpiralEmitter=Class'XEffects.Spiral'
     bDelayedSpawn=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_rc.AmmoChargerMesh'
     bStatic=False
     Texture=None
     DrawScale=0.800000
     CollisionRadius=60.000000
     CollisionHeight=6.000000
}
