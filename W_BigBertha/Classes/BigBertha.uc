//===================================================================================================================================================================================//
// BigBertha ARTY. This one has lobs Mass Electronic Gyroscopic Assisted Self Propelled Advanced Modular Explosive Rounds (MEGASPAMER!).  Credit all goes to RS and teh community :P //
//===================================================================================================================================================================================//
class BigBertha extends ONSArtillery
	placeable;


// Decompiled with UE Explorer.
defaultproperties
{
     DriverWeapons(0)=(WeaponClass=Class'W_BigBertha.BigBerthaCannon',WeaponBone="CannonAttach")
     PassengerWeapons(0)=(WeaponPawnClass=Class'OnslaughtBP.ONSArtillerySideGunPawn',WeaponBone="SideGunAttach")
     RedSkin=Texture'BerthaTextures.Skins.SPMARedBlack'
     BlueSkin=Texture'BerthaTextures.Skins.SPMABlueBlack'


    TPCamDistance=875.0
    VehiclePositionString="in an Howitzer SPMA"
    VehicleNameString="Howitzer SPMA"
    RanOverDamageType=class'DamTypeBigBerthaRoadkill'
    CrushedDamageType=class'DamTypeBigBerthaPancake'
}
