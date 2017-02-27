#exec OBJ LOAD FILE=EpicParticles.utx
#exec OBJ LOAD FILE=2K4HUD.utx

class WeaponRotatorPickup extends UTWeaponPickup;

function SetWeaponStay()
{
	bWeaponStay = false;
}

function float GetRespawnTime()
{
	return ReSpawnTime;
}



function StartSleeping()
{
    if (bDropped)
        Destroy();
    else if (!bWeaponStay)
	    GotoState('Sleeping');
}

function ChangeWeapon(){
     /*
    if(Rand(2) == 1){
     InventoryType=Class'W_BBRedeemer.BBRedeemer';
     PickupMessage="You got the Bunker Buster.";
     StaticMesh=StaticMesh'WeaponStaticMesh.RedeemerPickup';
     Skins(1)=Texture'W_ReedemerTex.Skins.RDMR_Missile_BLK';
     }else{
     InventoryType=Class'XWeapons.Redeemer';
     PickupMessage="You got the Reedemer.";
     StaticMesh=StaticMesh'WeaponStaticMesh.RedeemerPickup';
     Skins(1)=Texture'W_ReedemerTex.Skins.RDMR_Missile_BLU';
     }
     */

}

defaultproperties
{
     bWeaponStay=False
     MaxDesireability=1.000000
     InventoryType=Class'W_BBRedeemer.BBRedeemer'
     RespawnTime=120.000000
     PickupMessage="You got the Bunker Buster."
     PickupSound=Sound'PickupSounds.FlakCannonPickup'
     PickupForce="FlakCannonPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RedeemerPickup'
     DrawScale=0.900000
     Skins(1)=Texture'W_ReedemerTex.Skins.RDMR_Missile_BLK'
}
