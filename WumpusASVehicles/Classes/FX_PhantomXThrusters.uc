//=============================================================================
// FX_FighterThrusters.
//=============================================================================
class FX_PhantomXThrusters extends FX_PhantomXRunningLight;


var Material RedSkin,RedSkinB,BlueSkin,BlueSkinB;

var StaticMesh PhantomThrusters,FalconThrusters,SpacefighterThruster;
simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();

     SetStaticMesh(PhantomThrusters);
}
simulated function SetBlueColor()
{
    Team=1;
	Skins[0] = BlueSkin;
	Skins[1] = BlueSkinB;
}

simulated function SetRedColor()
{
    Team=0;
	Skins[0] = RedSkin;
	Skins[1] = RedSkinB;
}

simulated function SetInvisable()
{
   bHidden=true;
}

simulated function SetVisable()
{
   bHidden=False;
}

singular function BaseChange();

defaultproperties
{
     RedSkin=TexOscillator'APVerIV_Tex.AP_FX.EngineRedFlux'
     RedSkinB=TexRotator'APVerIV_Tex.AP_FX.RedCoreRot'
     BlueSkin=TexOscillator'APVerIV_Tex.AP_FX.EngineBlueFlux'
     BlueSkinB=TexRotator'APVerIV_Tex.AP_FX.BlueCoreRot'
     PhantomThrusters=StaticMesh'APVerIV_ST.AP_FX_ST.PhantomEngine'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'APVerIV_ST.AP_FX_ST.FighterEnginesRed'
     RemoteRole=ROLE_None
     DrawScale=1.000000
     Skins(0)=TexOscillator'APVerIV_Tex.AP_FX.EngineRedFlux'
     Skins(1)=TexRotator'APVerIV_Tex.AP_FX.RedCoreRot'
     Style=STY_Normal
}
