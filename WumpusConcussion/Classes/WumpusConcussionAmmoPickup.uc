class WumpusConcussionAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=10
     InventoryType=Class'WumpusConcussion.WumpusConcussionAmmo'
     PickupMessage="You picked up concussion ammo."
     PickupSound=Sound'PickupSounds.SniperAmmoPickup'
     PickupForce="WumpusSniperAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'NewWeaponStatic.ClassicSniperAmmoM'
     PrePivot=(Z=16.000000)
     CollisionHeight=16.000000
}
