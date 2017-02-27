class VortexPickup extends UTWeaponPickup;

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
       /*    TODO find materials!!!
static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(texture'vortex_launcher');
    L.AddPrecacheMaterial(combiner'screens_combined');
    L.AddPrecacheMaterial(finalblend'blue_flames_final');
    L.AddPrecacheMaterial(shader'Vortexshell_half');
    L.AddPrecacheMaterial(shader'Vortexshell_shaderfinal');
    L.AddPrecacheMaterial(texture'LightningBoltT');
    L.AddPrecacheMaterial(finalblend'Lightning1');
    L.AddPrecacheMaterial(shader'TransRing');
    L.AddPrecacheMaterial(finalblend'ShockDarkFB');
    L.AddPrecacheStaticMesh(staticmesh'CE_Vortexlauncher');
    //return;
}



simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(texture'vortex_launcher');
    Level.AddPrecacheMaterial(combiner'screens_combined');
    Level.AddPrecacheMaterial(finalblend'blue_flames_final');
    Level.AddPrecacheMaterial(shader'Vortexshell_half');
    Level.AddPrecacheMaterial(shader'Vortexshell_shaderfinal');
    Level.AddPrecacheMaterial(texture'LightningBoltT');
    Level.AddPrecacheMaterial(finalblend'Lightning1');
    Level.AddPrecacheMaterial(shader'TransRing');
    Level.AddPrecacheMaterial(finalblend'ShockDarkFB');
    //return;
}
*/

defaultproperties
{
   /* StandUp=(X=0.250,Y=0.250,Z=0.0)*/
    bWeaponStay=false
    MaxDesireability=0.750
    InventoryType=class'Vortex'
    RespawnTime=120.0
    PickupMessage="You got the Gravity Vortex."
    PickupSound=Sound'ChaosEsounds1.Vortex.vortex_pickup'
    PickupForce="FlakCannonPickup"
    StaticMesh=StaticMesh'W_Vortex-Mesh.Weapons.CE_Vortexlauncher'
    DrawScale=0.150
    DrawType=DT_StaticMesh

/*    DrawScale=0.150
Skins(0)=Texture'W_Vortex-Tex.vortex_launcher.vortex_launcher'
Skins(1)=Combiner'W_Vortex-Tex.vortex_launcher.screens_combined'
Skins(2)=FinalBlend'W_Vortex-Tex.vortex_launcher.blue_flames_final'
Skins(3)=Shader'W_Vortex-Tex.vortex_launcher.Vortexshell_half'
Skins(4)=Shader'W_Vortex-Tex.vortex_launcher.Vortexshell_shaderfinal'
                     */

}
