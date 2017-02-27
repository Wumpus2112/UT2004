/*******************************************************************************
 * VortexAmmoPickup generated by Eliot.UELib using UE Explorer.
 * Eliot.UELib ? 2009-2013 Eliot van Uytfanghe. All rights reserved.
 * http://eliotvu.com
 *
 * All rights belong to their respective owners.
 *******************************************************************************/
class QuantumAmmoPickup extends UTAmmoPickup;

defaultproperties
{
    AmmoAmount=1
    MaxDesireability=0.320
    InventoryType=class'QuantumAmmo'
    PickupMessage="You picked up another Quantum Projector."
    PickupSound=Sound'PickupSounds.FlakAmmoPickup'
    PickupForce="FlakAmmoPickup"
    DrawType=8
    StaticMesh=StaticMesh'WeaponStaticMesh.BioAmmoPickup'
    CollisionHeight=8.250
}
