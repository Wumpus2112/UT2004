//=======================================================================================================//
// Hellfire BigBertha ARTY. This one has Multi Warheads. :D Credit all goes to RS and teh community :P//
//=======================================================================================================//
class HellfireBigBertha extends ONSArtillery
	placeable;


// Decompiled with UE Explorer.
defaultproperties
{
     DriverWeapons(0)=(WeaponClass=Class'W_BigBertha.HellfireBigBerthaCannon',WeaponBone="CannonAttach")
     PassengerWeapons(0)=(WeaponPawnClass=Class'OnslaughtBP.ONSArtillerySideGunPawn',WeaponBone="SideGunAttach")

     RedSkin=Texture'BerthaTextures.Skins.SPMARed'
     BlueSkin=Texture'BerthaTextures.Skins.SPMABlue'

    TPCamDistance=875.0
    VehiclePositionString="in an Mark II SPMA"
    VehicleNameString="Mark II SPMA"
    RanOverDamageType=class'DamTypeHFBigBerthaRoadkill'
    CrushedDamageType=class'DamTypeHFBigBerthaPancake'
}
