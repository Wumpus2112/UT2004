//-----------------------------------------------------------
//
//-----------------------------------------------------------
class wGlitchDeathMatch extends wDeathMatch;

#exec OBJ LOAD FILE="..\Sounds\GlitchModSounds.uax" //This may or may not require you to put this line in.

var string ComboNames[6];
var int    GlitchCountdown;
var int    GlitchEventCounter;

var string ComboName;

var CameraEffect blurEffect;
var MotionBlur MotionBlur;
var CameraOverlay CameraOverlay;

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
var int         GlitchHead;



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

var bool isFirstGlitch;

var class<Weapon> WeaponClassBioRifle;
var class<Weapon> WeaponClassFlakCannon;
var class<Weapon> WeaponClassLinkGun;
var class<Weapon> WeaponClassMinigun;
var class<Weapon> WeaponClassRocketLauncher;
var class<Weapon> WeaponClassShockRifle;
var class<Weapon> WeaponClassSniperRifle;

var bool bMatchStarted;
var bool bMatchOver;

state MatchInProgress
{
    event Timer()
    {
        Super.Timer(); // Need this!!!
        GlitchTimer();
    }


}

State MatchOver
{
    event Timer()
    {
        local GlitchModGameReplicationInfo gri;

        Super.Timer(); // Need this!!!

        if(bMatchOver){
            isEndGlitch=true;
            invokeGlitch();
            isEndGlitch=false;

            GlitchTypeCurrent = GlitchFly;  // no client effects, no averse server effects

            //update glitch mod number
            gri = GlitchModGameReplicationInfo(GameReplicationInfo);
            gri.GlitchNumber = GlitchTypeCurrent;
        }
    }


}
/*
simulated function UpdateLocations(){
    local GlitchModGameReplicationInfo glitchGRI;
    glitchGRI = GlitchModGameReplicationInfo(GameReplicationInfo);
}
*/
function GlitchTimer(){
    local GlitchModGameReplicationInfo gri;

    say("GlitchTimer: "$GlitchCountdown$" ["$ElapsedTime$"]");

    GlitchCountdown--;
    if(GlitchCountdown < 5 && GlitchTypeNext == GlitchTypeCurrent){
        while(GlitchTypeNext == GlitchTypeCurrent){
            GlitchTypeNext = Rand(GlitchTotal);
            //GlitchTypeNext = GlitchTypeCurrent + 1;
        }
        /* announce the next glitch*/
        announceGlitch(GlitchTypeNext);
    }


    if(GlitchCountdown < 1){
        isEndGlitch=true;
        invokeGlitch();
        isEndGlitch=false;

        GlitchTypeCurrent = GlitchTypeNext;

        GlitchCountdown=60;

        isStartGlitch=true;
        invokeGlitch();
        isStartGlitch=false;

        //update glitch mod number
        gri = GlitchModGameReplicationInfo(GameReplicationInfo);
        gri.GlitchNumber = GlitchTypeCurrent;
    }

     if((GlitchCountdown % GlitchEventCounter) == 0){
         isGlitchOn=true;
         invokeGlitch();
         isGlitchOn=false;
     }

     if(isFirstGlitch){
         announceGlitch(100);
         isFirstGlitch = false;

     }

}

function announceGlitch(int i){

    local sound glitchSound;
    local PlayerController c;

     switch(GlitchTypeNext){
         case GlitchFast:
              say("GlitchFast");
              glitchSound=sound'GlitchModSounds.WeCantStop';
        break;

         case GlitchSlow:
              say("GlitchSlow");
              glitchSound=sound'GlitchModSounds.Matrix';
         break;

         case GlitchWeapons:
              say("GlitchWeapons");
              glitchSound=sound'GlitchModSounds.OhMyGod';
         break;

         case GlitchNoWeapons:
              say("GlitchNoWeapons");
              glitchSound=sound'GlitchModSounds.RaiseYourWeapon';
         break;

         case GlitchPort:
              say("GlitchPort");
              glitchSound=sound'GlitchModSounds.AnimalRights';
         break;

         case GlitchVis:
              say("GlitchVis");
              glitchSound=sound'GlitchModSounds.OhYea';
         break;

         case GlitchMove:
              say("GlitchMove");
              glitchSound=sound'GlitchModSounds.Control';
         break;

         case GlitchGrav:
              say("GlitchGrav");
              glitchSound=sound'GlitchModSounds.Digitalism';
         break;

         case GlitchFly:
              say("GlitchFly");
              glitchSound=sound'GlitchModSounds.DevilsDen';
         break;

         case GlitchSpider:
              say("GlitchSpider");
              glitchSound=sound'GlitchModSounds.Timestretch';
         break;

/**/
         case GlitchInvis:
              say("GlitchInvis");
              glitchSound=sound'GlitchModSounds.Body';
         break;

         case GlitchMini:
              say("GlitchMini");
              glitchSound=sound'GlitchModSounds.MeAndYou';
         break;

         case GlitchCamo:
              say("GlitchCamo");
              glitchSound=sound'GlitchModSounds.IAm';
         break;

         case GlitchHealth:
              say("GlitchHealth");
              glitchSound=sound'GlitchModSounds.Slam';
         break;

         case GlitchHead:
              say("GlitchHead");
              glitchSound=sound'GlitchModSounds.Lick';
         break;

         default:
              //say("No Glitch Found");
              glitchSound=sound'GlitchModSounds.CantKill';

    }

        foreach DynamicActors(class'PlayerController', c){
             c.PlayAnnouncement(glitchSound, 1, true);
             c.ReceiveLocalizedMessage(class'W_GlitchMod.GlitchMessages', GlitchTypeNext);
        }

}

function invokeGlitch(){

     switch(GlitchTypeCurrent){
         case GlitchFast:
             FGlitchFast();
         break;

         case GlitchSlow:
             FGlitchSloMo();
         break;

         case GlitchWeapons:
             FGlitchAllWeapons();
         break;

         case GlitchNoWeapons:
             FGlitchShieldOnly();
         break;

         case GlitchPort:
             FGlitchTeleport();
         break;

         case GlitchVis:
             FGlitchVis();
         break;

         case GlitchMove:
             FGlitchMove();
         break;

         case GlitchGrav:
             FGlitchAirHead();
         break;

         case GlitchFly:
             FGlitchFly();
         break;

         case GlitchSpider:
             FGlitchSpider();
         break;

         case GlitchInvis:
             FGlitchInvis();
         break;

         case GlitchMini:
             FGlitchTiny();
         break;

         case GlitchCamo:
             FGlitchCamo();
         break;

         case GlitchHealth:
             FGlitchHealth();
         break;

         case GlitchHead:
             FGlitchBigHead();
         break;


         default:
    }

}

function PostBeginPlay()
{
    Initialize();
    Super.PostBeginPlay();
}

function Initialize(){
    say("Initialize");

    SetTimer(1.0,true);

	WeaponClassBioRifle = class<Weapon>(DynamicLoadObject("XWeapons.BioRifle", class'Class'));
	WeaponClassFlakCannon = class<Weapon>(DynamicLoadObject("XWeapons.FlakCannon", class'Class'));
	WeaponClassLinkGun = class<Weapon>(DynamicLoadObject("XWeapons.LinkGun", class'Class'));
	WeaponClassMinigun = class<Weapon>(DynamicLoadObject("XWeapons.Minigun", class'Class'));
	WeaponClassRocketLauncher = class<Weapon>(DynamicLoadObject("XWeapons.RocketLauncher", class'Class'));
	WeaponClassShockRifle = class<Weapon>(DynamicLoadObject("XWeapons.ShockRifle", class'Class'));
	WeaponClassSniperRifle = class<Weapon>(DynamicLoadObject("XWeapons.SniperRifle", class'Class'));

/*
	GlitchTypes[0]= GlitchFast;
	GlitchTypes[1]= GlitchSlow;
	GlitchTypes[2]= GlitchCombo;
	GlitchTypes[3]= GlitchWeapons;
	GlitchTypes[4]= GlitchNoWeapons;
	GlitchTypes[5]= GlitchPort;
	GlitchTypes[6]= GlitchVis;
	GlitchTypes[7]= GlitchMove;
	GlitchTypes[8]= GlitchGrav;
*/
    GlitchTypeCurrent = 99;
    GlitchTypeNext = 99;
    GlitchCountdown = 10;

    bMatchStarted=false;
    isFirstGlitch=true;
    // start game

}


/*******************************************/
/* Glitches!!!!                            */
/*******************************************/




/* slo mo */
function FGlitchSloMo(){
    if(isStartGlitch){
       	Level.Game.bAllowMPGameSpeed = true;
    	Level.Game.SetGameSpeed(0.25);
        //GlitchCountdown=20;
        GlitchEventCounter=100;

    //Level.Game.bAllowMPGameSpeed = true;
    //Level.Game.SetGameSpeed(NewGameSpeed);
    }
    if(isGlitchOn){

    }
    if(isEndGlitch){
    	Level.Game.SetGameSpeed(1.0);
    }
}

/* fast */
function FGlitchFast(){
    if(isStartGlitch){
       	Level.Game.bAllowMPGameSpeed = true;
    	Level.Game.SetGameSpeed(3.0);
       // GlitchCountdown=120;
       GlitchEventCounter=100;
    }
    if(isGlitchOn){

    }
    if(isEndGlitch){
    	Level.Game.SetGameSpeed(1.0);
    }
}

/*
     ComboNames(0)="xGame.ComboSpeed"
     ComboNames(1)="xGame.ComboBerserk"
     ComboNames(2)="xGame.ComboDefensive"
     ComboNames(3)="xGame.ComboInvis"
     ComboNames(4)="BonusPack.ComboMiniMe"
     ComboNames(5)="BonusPack.ComboCrate"

     ComboName = ComboNames[Rand(ArrayCount(ComboNames))];
*/

function FGlitchInvis(){
        if(isStartGlitch) ComboName = ComboNames[3];
    ExeGlitchCombo();
}

function FGlitchTiny(){
    if(isStartGlitch) ComboName = ComboNames[4];
    ExeGlitchCombo();
}

function FGlitchHealth(){
    if(isStartGlitch) ComboName = ComboNames[2];
    ExeGlitchCombo();
}

function FGlitchCamo(){
    if(isStartGlitch) ComboName = ComboNames[5];
    ExeGlitchCombo();
}

/* addreniline combos */
function ExeGlitchCombo(){
    local Controller c;
    local Pawn p;
    local xPawn x;


    if(isStartGlitch){
        foreach DynamicActors(class'Controller', c){
            p = c.Pawn;
            if(p == none) return;
            p.RemovePowerups();
            c.Adrenaline = 100;
        	p.DoComboName(ComboName);
        }
       GlitchEventCounter=5;
    }

    if(isGlitchOn){
        foreach DynamicActors(class'Controller', c){
            p = c.Pawn;
            if(p == none) return;
            x = xPawn(p);
            if(x == none) return;
            c.Adrenaline = 100;
            if(x.CurrentCombo == none){
         	    p.DoComboName(ComboName);
         	}
        }
    }
    if(isEndGlitch){
        foreach DynamicActors(class'Controller', c){
            p = c.Pawn;
            if(p == none) return;
            p.RemovePowerups();
            c.Adrenaline = 0;
        }
    }

}

simulated function FGlitchVis(){
//    local PlayerController c;
//    local Pawn p;

    if(isStartGlitch){
       // GlitchCountdown=120;
       GlitchEventCounter=100;
    }

    if(isGlitchOn){
    /*
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
      */
    }

    if(isEndGlitch){
    /*
        SetTimer(1.0,true);
        foreach DynamicActors(class'PlayerController', c){
            p = c.Pawn;
         //   c.RemoveCameraEffect(MotionBlur);
         //   c.RemoveCameraEffect(CameraOverlay);
            c.setFOV(100);
        }
      */
    }

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
//    local PlayerController c;
//    local Rotator changeYaw;

    if(isStartGlitch){
       GlitchEventCounter=100;
    }
    /*
    if(isGlitchOn){
        foreach DynamicActors(class'PlayerController', c){
            changeYaw = c.Rotation;
            changeYaw.Yaw = changeYaw.Yaw + Rand(8192)-4096;
            changeYaw.Pitch = changeYaw.Pitch + Rand(8192)-4096;
            c.SetRotation(changeYaw);
        }
    }
    */
    if(isEndGlitch){
    }
}

/* no weapon control
function NoWeaponControl(){
   Controller.
}
*/


function FGlitchFly(){
    local PlayerController c;

    if(isStartGlitch){
       GlitchEventCounter=5;
        foreach DynamicActors(class'PlayerController', c){
            GlitchPlayerFly(c);
        }
    }
    if(isGlitchOn){
        foreach DynamicActors(class'PlayerController', c){
            GlitchPlayerFly(c);
        }
    }
    if(isEndGlitch){
        foreach DynamicActors(class'PlayerController', c){
            GlitchPlayerWalk(c);
        }
    }
}

function FGlitchSpider(){
    local PlayerController c;

    if(isStartGlitch){
       GlitchEventCounter=5;
        foreach DynamicActors(class'PlayerController', c){
            GlitchSpiderman(c);
        }
    }
    if(isGlitchOn){
        foreach DynamicActors(class'PlayerController', c){
            GlitchSpiderman(c);
        }
    }
    if(isEndGlitch){
        foreach DynamicActors(class'PlayerController', c){
            GlitchPlayerWalk(c);
        }
    }
}


/* all weapons */

function FGlitchAllWeapons(){
    local Controller c;
    local xPawn p;
    local Inventory Inv;

    if(isStartGlitch){
        Level.GRI.WeaponBerserk = 4;

        foreach DynamicActors(class'Controller', c){
            AddAllWeapons(c);
            p = xPawn(c.Pawn);

            if(p != none){
        		// Set Berserk on
	        	if (p.Weapon != None){
		        	p.Weapon.CheckSuperBerserk();
    		        p.bBerserk = true;
                }
		    }
        }
        GlitchEventCounter=10;

    }

    if(isGlitchOn){
        foreach DynamicActors(class'xPawn', p){
            for ( Inv=p.Inventory; Inv!=None; Inv=Inv.Inventory )
            {
                if ( Weapon(Inv) != None )
                    Weapon(Inv).SuperMaxOutAmmo();
            }

        }

    }

    if(isEndGlitch){

        Level.GRI.WeaponBerserk = 1;

        foreach DynamicActors(class'Controller', c){
            p = xPawn(c.Pawn);
            if(p!= none){
                DeleteInventory(p);
        		// Turn Berserk off
	        	for( Inv=p.Inventory; Inv!=None; Inv=Inv.Inventory )
		        {
			        if (Inv.IsA('Weapon'))
				        Weapon(Inv).StopBerserk();
    		    }

	    	    p.bBerserk = false;
            }
        }

    }

}


function AddAllWeapons(Controller c){
    local Pawn p;
    local xPawn x;
    local Inventory Inv;

        p = c.Pawn;
        if(p == None) return;
        x = xPawn(p);
        if(x != None)
        {
            x.CreateInventory("XWeapons.BioRifle");
            x.CreateInventory("XWeapons.FlakCannon");
            x.CreateInventory("XWeapons.LinkGun");
            x.CreateInventory("XWeapons.Minigun");
            x.CreateInventory("XWeapons.RocketLauncher");
            x.CreateInventory("XWeapons.ShockRifle");
            x.CreateInventory("XWeapons.SniperRifle");

            for( Inv=x.Inventory; Inv!=None; Inv=Inv.Inventory )
            {
                if ( Weapon(Inv) != None )
                    Weapon(Inv).SuperMaxOutAmmo();
            }
        }


}





/* shieldgun only */
function FGlitchShieldOnly(){
    local Pawn p;
    local Controller c;

    if(isStartGlitch){

        foreach DynamicActors(class'Controller', c){
            p = c.Pawn;
            if(p == None) return;
            DeleteInventory(p);
        }
       GlitchEventCounter=2;
    }

    if(isGlitchOn){
        foreach DynamicActors(class'Controller', c){
            p = c.Pawn;
            if(p == None) return;
            DeleteAmmo(p);
        }
    }

    if(isEndGlitch){

    }

}


function DeleteInventory(Pawn p)
{
    local xPawn x;

    x = xPawn(p);
    if(x != None)
    {
        DeleteItem(p, WeaponClassBioRifle);
        DeleteItem(p, WeaponClassFlakCannon);
        DeleteItem(p, WeaponClassLinkGun);
        DeleteItem(p, WeaponClassMinigun);
        DeleteItem(p, WeaponClassRocketLauncher);
        DeleteItem(p, WeaponClassShockRifle);
        DeleteItem(p, WeaponClassSniperRifle);
    }
}

function DeleteItem(Pawn p, class c){
    local Inventory i;
    i = p.FindInventoryType(c);
    if(i != none){
        p.DeleteInventory(i);
    }
    return;
}

function DeleteAmmo(Pawn p){
    local Inventory Inv;
    for( Inv=p.Inventory; Inv!=None; Inv=Inv.Inventory )
    {
        if ( Weapon(Inv) != None ){
            Weapon(Inv).ConsumeAmmo(0,1000,true);
            Weapon(Inv).ConsumeAmmo(1,1000,true);
        }
    }
}




/* air head */
function FGlitchAirHead(){

    local Controller c;
    local Pawn p;

    if(isStartGlitch){
    /*
    foreach AllActors(class'PhysicsVolume', PV){
        DefaultGravity = PV.Gravity;
		PV.BACKUP_Gravity = PV.Gravity;
        PV.Gravity.Z = -300;
		PV.bAlwaysRelevant = true;
		PV.RemoteRole = ROLE_DumbProxy;
		log("********** found physics Volume ********************************************************");
	}
    */
	DefaultGravity = PhysicsVolume.Gravity;
	PhysicsVolume.Gravity.Z = -300.0;

/*
        defaultGravity = Level.Game.KGetActorGravScale();
        Level.Game.KSetActorGravScale(0.1);
*/
       foreach DynamicActors(class'Controller', c){
           p = c.Pawn;
           if(p != None)
           {
        		p.AirControl = p.Default.AirControl * 5;
        		//p.GroundSpeed = p.Default.GroundSpeed * 5;
        		//p.WaterSpeed = p.Default.WaterSpeed * 5;
        		p.AirSpeed = p.Default.AirSpeed * 5;
        		//p.JumpZ = 0;
           }
       }

       GlitchEventCounter=100;

    }

    if(isGlitchOn){

    }

    if(isEndGlitch){
    /*
    foreach AllActors(class'PhysicsVolume', PV){
        PV.Gravity = DefaultGravity;
		PV.BACKUP_Gravity = PV.Gravity;
		PV.bAlwaysRelevant = true;
		PV.RemoteRole = ROLE_DumbProxy;
	}
    */
    PhysicsVolume.Gravity = DefaultGravity;

       foreach DynamicActors(class'Controller', c){
           p = c.Pawn;
           if(p != None)
           {
               Level.Game.SetPlayerDefaults(p);
           }
       }
    }
}



function FGlitchTeleport(){
    local Controller c;
    local Pawn p;
    local xPawn x;

    if(isStartGlitch){
        foreach DynamicActors(class'Controller', c){
            if(p != none) p = c.Pawn;
            x = xPawn(p);
            if(x != None)
            {
               RandomTeleport(c,x);
            }
        }
       GlitchEventCounter=10;
    }

    if(isGlitchOn){
        foreach DynamicActors(class'Controller', c){
            p = c.Pawn;
            if(p != none) x = xPawn(p);
            if(x != None)
            {
               RandomTeleport(c,x);
            }
        }
    }

    if(isEndGlitch){

    }

}

function RandomTeleport(Controller Pred, xPawn PredPawn)
{
	local NavigationPoint N;
	local PlayerController pcPred;

	N = Level.Game.FindPlayerStart(Pred);

	if(N == None)
	{
		Log("Could not teleport Mutant");
		return;
	}

	Pred.SetLocation(N.Location);
	Pred.SetRotation(N.Rotation);

	PredPawn.SetLocation(N.Location);
	PredPawn.SetRotation(N.Rotation);
	PredPawn.Velocity = vect(0,0,0);

	Pred.ClientSetLocation(N.Location, N.Rotation);

	// Flash clients screen purple
	pcPred = PlayerController(Pred);
	if(pcPred != None)
		pcPred.ClientFlash(0.1, vect(700,0,700));
}

function FGlitchBigHead(){
    local Pawn p;
    local Controller c;
//    local float headScale;

//	local BigHeadRules G;

    if(isStartGlitch){
/*
    	G = spawn(class'BigHeadRules');
    	G.BigHeadMutator = self;
	    if ( Level.Game.GameRulesModifiers == None )
		    Level.Game.GameRulesModifiers = G;
    	else
	    	Level.Game.GameRulesModifiers.AddGameRules(G);
*/

        foreach DynamicActors(class'Controller', c){
            p = c.Pawn;
        	if(p != none) p.SetHeadScale(GetHeadScaleFor(p));
        }
        GlitchEventCounter = 3;
    }

    if(isGlitchOn){
        foreach DynamicActors(class'Controller', c){
            p = c.Pawn;
        	if(p != none) p.SetHeadScale(GetHeadScaleFor(p));
        }
    }

    if(isEndGlitch){
        foreach DynamicActors(class'Controller', c){
            p = c.Pawn;
        	if(p != none) p.SetHeadScale(1);
        }
    }

}


function float GetHeadScaleFor(Pawn P)
{
	/*
	local float NewScale;

	if ( abs(P.PlayerReplicationInfo.Deaths) < 1 )
		NewScale = P.PlayerReplicationInfo.Score + 1;
	else
		NewScale = (P.PlayerReplicationInfo.Score+1)/(P.PlayerReplicationInfo.Deaths+1);
	return FClamp(NewScale, 0.5, 4.0);
	*/
	return 4.0;
}


function say(String s){
   /*
   local Controller C;

   log("wGlitchGame Glitch Mod: "$s);

        for( C = Level.ControllerList; C != None; C = C.NextController ){
            if ( C != None ){
                if ( C.IsA('PlayerController') ){
                    PlayerController(C).ClientMessage("Glitch Mod: "$s);
                }
            }
        }
     */
}





function function GlitchSpiderman(PlayerController pc)
{
		pc.GotoState('PlayerSpidering');
}

function function GlitchPlayerFly(PlayerController pc)
{
		pc.bCheatFlying = true;
		pc.GotoState('PlayerFlying');
}

function function GlitchPlayerWalk(PlayerController pc)
{
		pc.bCheatFlying = false;
		pc.GotoState('PlayerWalking');
}




defaultproperties
{

    MaxGlitchFOV=150
    MinGlitchFOV=80
    NowGlitchFOV=80
    IncGlitchFOV=1

     ComboNames(0)="xGame.ComboSpeed"
     ComboNames(1)="xGame.ComboBerserk"
     ComboNames(2)="xGame.ComboDefensive"
     ComboNames(3)="xGame.ComboInvis"
     ComboNames(4)="BonusPack.ComboMiniMe"
     ComboNames(5)="BonusPack.ComboCrate"

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
    GlitchHead=14

    GlitchTotal=15

    NausiaMaterial=Shader'XEffectMat.Shield.Shader3'

    GameReplicationInfoClass=Class'W_GlitchMod.GlitchModGameReplicationInfo'

     HUDType="W_GlitchMod.HudGlitchMod"
     GameName="GlitchModDeathMatch"
     Acronym="GDM"
}
