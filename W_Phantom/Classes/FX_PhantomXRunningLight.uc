//=============================================================================
// FX_RunningLight.
//=============================================================================
class FX_PhantomXRunningLight extends ScaledSprite;
#exec OBJ LOAD FILE=W_Dragon-TX.utx
var() float ExtinguishTime;
var int Team;
singular function BaseChange();

simulated function SetBlueColor()
{
    Team=1;
	Texture=Texture'W_Dragon-TX.AP_FX.BlueFlash';
}

simulated function SetRedColor()
{
    Team=0;
	Texture=Texture'W_Dragon-TX.AP_FX.RedFlash';
}

simulated function SetInvisable()
{
   bHidden=true;
}

simulated function SetVisable()
{
   bHidden=False;
}

defaultproperties
{
     ExtinguishTime=1.500000
     bStatic=False
     bStasis=False
     Texture=Texture'W_Dragon-TX.AP_FX.RedFlash'
     DrawScale=0.500000
     Style=STY_Additive
     bShouldBaseAtStartup=False
     bHardAttach=True
     Mass=0.000000
}
