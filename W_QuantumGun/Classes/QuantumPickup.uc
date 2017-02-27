class QuantumPickup extends UTWeaponPickup;

function SetWeaponStay()
{
    bWeaponStay = false;
    //return;
}

function float GetRespawnTime()
{
    return RespawnTime;
    //return;
}


defaultproperties
{

    bWeaponStay=false
    MaxDesireability=0.750
    InventoryType=class'QuantumGun'
    RespawnTime=120.0
    PickupMessage="You got the Quantum Projector."
     PickupSound=Sound'PickupSounds.FlakCannonPickup'
    PickupForce="FlakCannonPickup"
    StaticMesh=StaticMesh'W_Vortex-Mesh.Weapons.CE_Vortexlauncher'
    DrawScale=0.150
    DrawType=DT_StaticMesh



}
