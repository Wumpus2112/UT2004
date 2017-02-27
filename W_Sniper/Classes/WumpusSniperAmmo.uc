class WumpusSniperAmmo extends Ammunition;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     MaxAmmo=250
     InitialAmount=50
     bTryHeadShot=True
     PickupClass=Class'W_Sniper.WumpusSniperAmmoPickup'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=451,Y1=445,X2=510,Y2=500)
     ItemName="Sniper Bullets"
}
