class HUDGlitchMod extends HudCTeamDeathMatch
	config(user);

//#EXEC OBJ LOAD FILE=InterfaceContent.utx
//#EXEC OBJ LOAD FILE=AS_FX_TX.utx

var int    GlitchCountdown;
var int    GlitchEventCounter;
var float  CurrentIntervalTime;
var float  EventIntervalTime;

var CameraEffect blurEffect;
var MotionBlur MotionBlur;
var CameraOverlay CameraOverlay;

var bool isInitialized;

var float bezerkDefault;

var Material NausiaMaterial;

var vector DefaultGravity;

var int         GlitchFast;
var int         GlitchSlow;
var int         GlitchWeapons;
var int         GlitchNoWeapons;
var int         GlitchPort;
var int         GlitchVis;
var int         GlitchMove;
var int         GlitchGrav;
var int         GlitchFly;
var int         GlitchSpider;
var int         GlitchInvis;
var int         GlitchMini;
var int         GlitchCamo;
var int         GlitchHealth;

var int GlitchTotal;
var int GlitchTypeCurrent;
var int GlitchTypeNext;

var float MaxGlitchFOV;
var float MinGlitchFOV;
var float NowGlitchFOV;
var float IncGlitchFOV;

var bool isStartGlitch;
var bool isGlitchOn;
var bool isEndGlitch;

var int currentGlitch;

simulated function Tick(float DeltaTime)
{
	local GlitchModGameReplicationInfo glitchGRI;
	local int gameGlitchNumber;

    initialize();

    glitchGRI = GlitchModGameReplicationInfo( PlayerOwner.GameReplicationInfo );
    if(glitchGRI != none){
        gameGlitchNumber = glitchGRI.GlitchNumber;
        if(gameGlitchNumber != GlitchTypeCurrent){

            isEndGlitch=true;
            invokeGlitch();
            isEndGlitch=false;

            GlitchTypeCurrent = gameGlitchNumber;

            isStartGlitch=true;
            invokeGlitch();
            isStartGlitch=false;

        }
    }
    /*
    CurrentIntervalTime = CurrentIntervalTime - DeltaTime;
    if(CurrentIntervalTime < 0){
        // do event
        CurrentIntervalTime = EventIntervalTime + CurrentIntervalTime;
    }
    */
    Super.Tick(DeltaTime);
}

simulated function Timer(){
         isGlitchOn=true;
         invokeGlitch();
         isGlitchOn=false;
}

simulated function initialize(){
    if(isInitialized) return;
    isInitialized = true;

    SetTimer(1.0,true);
}

simulated function ChangeGlitch(int gameGlitchNumber){
    say("hud glitch:"$gameGlitchNumber);
    //announceGlitch(gameGlitchNumber);
}


simulated function GlitchTimer(){

     if((GlitchCountdown % GlitchEventCounter) == 0){
         isGlitchOn=true;
         invokeGlitch();
         isGlitchOn=false;
     }

}

simulated function invokeGlitch(){

     switch(GlitchTypeCurrent){
         case GlitchFast:
//             FGlitchFast();
         break;

         case GlitchSlow:
//             FGlitchSloMo();
         break;

         case GlitchWeapons:
//             FGlitchAllWeapons();
         break;

         case GlitchNoWeapons:
//             FGlitchShieldOnly();
         break;

         case GlitchPort:
//             FGlitchTeleport();
         break;

         case GlitchVis:
             FGlitchVis();
         break;

         case GlitchMove:
             FGlitchMove();
         break;

         case GlitchGrav:
//             FGlitchAirHead();
         break;

         case GlitchFly:
//             FGlitchFly();
         break;

         case GlitchSpider:
//             FGlitchSpider();
         break;

         default:
    }

}




simulated function FGlitchVis(){
    local PlayerController c;
    local Pawn p;

    c = PlayerOwner;


    if(isStartGlitch){
    /*
        if(MotionBlur == none){
            MotionBlur = MotionBlur(GetCameraEffect(class'MotionBlur'));
            MotionBlur.Alpha = 1.0;
            MotionBlur.BlurAlpha = 128;
            MotionBlur.FinalEffect = false;
        }
     */
        /*
        if(CameraOverlay == none)
        {
            CameraOverlay = CameraOverlay(GetCameraEffect(class'CameraOverlay'));
            CameraOverlay.OverlayMaterial = NausiaMaterial;
//            CameraOverlay.Alpha = 1.0;
            CameraOverlay.Alpha = 0.1;
            CameraOverlay. FinalEffect = false;
        }
        */
        foreach DynamicActors(class'PlayerController', c){
            p = c.Pawn;
       //     c.AddCameraEffect(MotionBlur);
           // c.AddCameraEffect(CameraOverlay);
            c.setFOV(MinGlitchFOV);
        }

        GlitchEventCounter=1;
        GlitchCountdown=6000;
        SetTimer(0.01,true);
    }

    if(isGlitchOn){
        NowGlitchFOV = NowGlitchFOV + IncGlitchFOV;
        if(NowGlitchFOV > MaxGlitchFOV){
            IncGlitchFOV = 0 - IncGlitchFOV;
            NowGlitchFOV = NowGlitchFOV + IncGlitchFOV;
        }

        if(NowGlitchFOV < MinGlitchFOV){
            IncGlitchFOV = 0 - IncGlitchFOV;
            NowGlitchFOV = NowGlitchFOV + IncGlitchFOV;
        }

        foreach DynamicActors(class'PlayerController', c){
            c.setFOV(NowGlitchFOV);
        }

    }

    if(isEndGlitch){
        SetTimer(1.0,true);
        foreach DynamicActors(class'PlayerController', c){
            p = c.Pawn;
         //   c.RemoveCameraEffect(MotionBlur);
         //   c.RemoveCameraEffect(CameraOverlay);
            c.setFOV(100);
        }

    }

}

simulated function CameraEffect GetCameraEffect(class<CameraEffect> CameraEffectClass){
    return CameraEffect(Level.ObjectPool.AllocateObject(CameraEffectClass));
}


/* visual problems
PlayerController.CreateCameraEffect
PlayerController.RemoveCameraEfect

MotionBlur
CameraOverlay



        if((MotionBlur == none) && MotionBlurWanted())
        {
            MotionBlur = MotionBlur(FindCameraEffect(class'MotionBlur'));
            MotionBlur.Alpha = 1.0;
            MotionBlur.BlurAlpha = 128;
            MotionBlur.FinalEffect = false;
        }

        if(CameraOverlay == none)
        {
            CameraOverlay = CameraOverlay(FindCameraEffect(class'CameraOverlay'));
            CameraOverlay.OverlayMaterial = LlamaScreenOverlayMaterial;
            CameraOverlay.Alpha = 1.0;
            CameraOverlay.FinalEffect = false;
        }
        bCameraEffectsEnabled = true;
*/


/* no camera control
Pawn.Rotation
*/

simulated function FGlitchMove(){
    local PlayerController c;
    local Rotator changeYaw;

    c = PlayerOwner;

    if(isStartGlitch){
       GlitchEventCounter=1;
    }
    if(isGlitchOn){
        foreach DynamicActors(class'PlayerController', c){
            changeYaw = c.Rotation;
            changeYaw.Yaw = changeYaw.Yaw + Rand(8192)-4096;
            changeYaw.Pitch = changeYaw.Pitch + Rand(8192)-4096;
            c.SetRotation(changeYaw);
        }
    }
    if(isEndGlitch){
    }
}

simulated simulated function DrawHudX(Canvas C)
{


}



function say(String s){
   local Controller C;

   log("GlitchHUD - Glitch Mod: "$s);

        for( C = Level.ControllerList; C != None; C = C.NextController ){
            if ( C != None ){
                if ( C.IsA('PlayerController') ){
                    PlayerController(C).ClientMessage("Glitch Mod: "$s);
                }
            }
        }

}





defaultproperties
{
    MaxGlitchFOV=150
    MinGlitchFOV=80
    NowGlitchFOV=80
    IncGlitchFOV=1

    GlitchFly=0
    GlitchVis=1
    GlitchGrav=2
    GlitchMove=3
    GlitchSpider=4
    GlitchFast=5
    GlitchSlow=6
    GlitchWeapons=7
    GlitchNoWeapons=8
    GlitchPort=9

    GlitchInvis=10
    GlitchMini=11
    GlitchCamo=12
    GlitchHealth=13

    GlitchTotal=14
}
