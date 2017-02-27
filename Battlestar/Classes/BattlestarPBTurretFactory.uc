//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BattlestarPBTurretFactory extends ASVehicleFactory_Turret;

DefaultProperties
{
    AIVisibilityDist=25000
    VehicleTeam=1
    VehicleClass=None
    VehicleClassStr="Battlestar.PBTurret"
    bEdShouldSnap=true

    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'AS_Weapons_SM.ASTurret_Editor'
    DrawScale=5.0
    AmbientGlow=96
}
