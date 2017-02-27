//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SpaceDualFighterRaptor extends SpaceDualFighterBase;

DefaultProperties
{
    Mesh=Mesh'RP.RP'
    RedSkin=texture'BSGVehicles.BSGVehicles.Raptor'
    BlueSkin=texture'BSGVehicles.BSGVehicles.Raptor'

    TrailEffectClass=class'Battlestar.DualAttackCraftExhaust'
    TrailEffectPositions(0)=(X=-160,Y=-33,Z=85);
    TrailEffectPositions(1)=(X=-160,Y=33,Z=85);
/*
    TrailEffectPositions(0)=(X=-160,Y=-33,Z=85);
    TrailEffectPositions(1)=(X=-160,Y=33,Z=85);

    TrailEffectPositions(2)=(X=-170,Y=-28,Z=85);
    TrailEffectPositions(3)=(X=-170,Y=28,Z=85);

    TrailEffectPositions(4)=(X=-170,Y=-38,Z=85);
    TrailEffectPositions(5)=(X=-170,Y=38,Z=85);

    TrailEffectPositions(6)=(X=-150,Y=-28,Z=85);
    TrailEffectPositions(7)=(X=-150,Y=28,Z=85);

    TrailEffectPositions(8)=(X=-150,Y=-38,Z=85);
    TrailEffectPositions(9)=(X=-150,Y=38,Z=85);
*/

    StreamerEffectOffset(0)=(X=-219,Y=-90,Z=57);
    StreamerEffectOffset(1)=(X=-219,Y=90,Z=57);
    StreamerEffectOffset(2)=(X=-219,Y=-100,Z=150);
    StreamerEffectOffset(3)=(X=-219,Y=100,Z=150);

}
