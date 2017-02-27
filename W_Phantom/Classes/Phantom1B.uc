//=============================================================================
// Phantom
// Fighter
// Pilot Controls Air to Air Missiles and Chaffe
//=============================================================================

class Phantom1B extends ASVehicle placeable;

//#exec OBJ LOAD FILE=AS_FX_TX.utx
//#exec OBJ LOAD FILE=W_Dragon-TX.utx
//#exec OBJ LOAD FILE=..\Animations\APVerIV_Anim.ukx
#exec OBJ LOAD FILE=..\Sounds\W_Phantom-SD.uax

var() float	LandingVelocityMax;		// Plane lands if collision slower than this

// BoilerPlate
var() float	EngineMinVelocity;		// minimum forward velocity

var	  Quat	SpaceFighterRotation;	// Space Fighter actual rotation (using quaternions instead of rotators)
var	  float	YawAccel;
var	  float	PitchAccel;
var	  float RollAccel;
var	  float	DesiredVelocity;		// Range: EngineMinVelocity -> 1000
var() float LandingEngineMinVelocity; // for no velocity
var() float	VehicleRotationSpeed;   //Speed of rotation
var() float VehiclePitchRotSpeed;
var() float VehicleYawRotSpeed;
var() float StrafeAccel;
var() float RollAutoCorrectSpeed;

var config float MenuYawSpeed;   // need to get players turnspeed
var config float MenuPitchSpeed; // for Yaw pitch and roll
var config float MenuRollSpeed;  // from config menu

var   float oldSpeed;
var   float LandingSpeed;
var   float TakeoffSpeed;

var() const float RotationInertia;
var config float LaunchSpeed;

var	bool bInitialized;			// this to catch first tick when match is started and velocity reset (so ship would always have a rotation==(0,0,0))
var	bool bPostNetCalled;
var	bool bSpeedFilterWarmup;

var bool bReadyForTakeOff;
var bool bLanded;
var bool bGearsDown;
var	bool bGearUp;				// Once flying animation is played

var bool bDamageHitWall;
var bool bDamageByPlayer;

var float DamMomentum;
var float Damage;
var float DamageRadius;
var float MomentumTransfer;
var class<DamageType> MyDamageType;

var array <float> DeathSpiralRotation;
var bool          bDeathRotation;
var int           DeathRotation;
var rotator       DeathSpiral;

// Engine Speed smooth filter (for velocity jerkyness on low and jerky FPS)
const			SpeedFilterFrames = 20;
var		float	SpeedFilter[SpeedFilterFrames];
var		int		NextSpeedFilterSlot;
var		float	SmoothedSpeedRatio;

// HUD
var texture   SpeedInfoTexture;
var Material  CrosshairTexture;

// Camera
var rotator	 LastCamRot;
var	float    myDeltaTime;
var	float    LastTimeSeconds;
var	float	 CamRotationInertia;

// FX
var name LandingGearsUp;
var name LandingGearsDown;
var	name FlyingAnim;
var FX_RunningLight      LeftWingLight,RightWingLight,BottomLight;
var FX_PhantomXThrusters Thruster;
var	Emitter  SmokeTrail;
var class<Emitter> ShotDownFXClass;
var ONSDualMissileSmokeTrail  DamageSmoke;

//Flyby sound Stuff
var float   FlybyRange;
var pawn    FlybyPawn;
var bool    bflyby;
var() sound FlybySound;
var vector  Flybyoffset;
var float   FlybyCountdown;
var float   FlybyInterval;
var	float   FlybyTraceDistance;

var() sound  LaunchSound;



replication
{
	reliable if ( bNetDirty && bNetOwner && Role==ROLE_Authority )
		oldSpeed;
    reliable if(Role==ROLE_Authority)
        bGearsDown;
	reliable if ( Role < ROLE_Authority )
	    bLanded,LandingEngineMinVelocity,DesiredVelocity,EngineMinVelocity;

    reliable if( bNetDirty && (Role==ROLE_Authority) )
		Thruster;

}

//////////////////////
// Init
//////////////////////


simulated event PostBeginPlay()
{
    VehicleYawRotSpeed=MenuYawSpeed * 0.001;
    VehiclePitchRotSpeed=MenuPitchSpeed * 0.001;
    VehicleRotationSpeed=MenuRollSpeed * 0.001;

	super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();

    DesiredVelocity = EngineMinVelocity + 10;
    bLanded =true;
	bPostNetCalled = true;
    DrivingStatusChanged();
}

simulated function Initialize(){
    bGearsDown=true;
    PlayAnim(LandingGearsDown);
}

//////////////////////
// END Init
//////////////////////


//////////////////////
// Tick and Timers
//////////////////////

simulated function Tick (float DeltaTime)
{
  local PlayerController PC;
  local	class<LocalMessage>	LockOnClass;

    if(IsInState('ShotDown')){
        bRotateToDesired = true;
	    bRollToDesired	= true;
        MyRandSpin(800);
        return;
    }

    if(Controller==None) return;

    CheckForBloody();


    // Listen for TakeOff
    if ( PlayerController(Controller).bPressedJump == true ){
        TakeOff();
        PlayerController(Controller).bPressedJump = false;
    }

    PC = PlayerController(Controller);

    if (Role==ROLE_Authority){
        // Missile Locking
        if ( Driver != None && Controller != None ){
		    if ( bEnemyLockedOn && PlayerController(Controller) != None && Level.TimeSeconds > LastLockWarningTime + 1.5){
			    LockOnClass = class<LocalMessage>(DynamicLoadObject(LockOnClassString, class'class'));
				PlayerController(Controller).ReceiveLocalizedMessage(LockOnClass, 12);
        		LastLockWarningTime = Level.TimeSeconds;
	        }
		}

        //Pilot has entered do stuff
        if (Controller!=none){
            //XXX         if ( AmbientSound != IdleSound ) AmbientSound = IdleSound;

            AdjustEngineFX();
            if( bflyby==false) Flyby();
        }
    }

    //Landing Gears
    if ( VSize(Velocity) < 210 ){
        if(bGearsDown==False){
            bGearsDown=true;
            PlayAnim(LandingGearsDown);
        }
    } else {
        if(bGearsDown==True) {
            bGearsDown=False;
            PlayAnim(LandingGearsUp);
        }
    }

    FlybyCountdown -= DeltaTime;

    if (FlybyCountdown <=0) bflyby=false;
}


simulated function CheckForBloody(){
    // Bloody
    if(Health < HealthMax / 2){
        if( DamageSmoke==none){
            //DamageSmoke=Spawn(class'FX_DamageSmokeTrail',self,,location);
            DamageSmoke=Spawn(class'ONSDualMissileSmokeTrail',self,,location);
            DamageSmoke.Setbase(self);
        }
    }else{
        if( DamageSmoke!=none){
            DamageSmoke=none;
        }
    }

}

//////////////////////
// END Tick and Timers
//////////////////////

//////////////////////
// HUD
//////////////////////


simulated function DrawVehicleHUD( Canvas C, PlayerController PC );



simulated function rotator GetViewRotation()
{
	  if ( IsLocallyControlled() && Health > 0)
		   return QuatToRotator(SpaceFighterRotation);	// true rotation
      else
            return rotation;
}

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local vector	x, y, z;
	local rotator	R;

	CameraLocation = Location;
	ViewActor	= Self;
	R			= GetViewRotation();
    GetAxes(R, x, y, z);

    // First-person view.
    CameraRotation = Normalize(R + PC.ShakeRot); // amb
    CameraLocation = CameraLocation +
                     PC.ShakeOffset.X * x +
                     PC.ShakeOffset.Y * y +
                     PC.ShakeOffset.Z * z;

	// Camera position is locked to vehicle
	CameraLocation = CameraLocation + (FPCamPos >> GetViewRotation());
}


//
// Targeting
//

/*
simulated function DrawVehicleHUD( Canvas C, PlayerController PC )
{
    local Vehicle	V;
    local vector	ScreenPos;
	local string	VehicleInfoString;

    C.Style		= ERenderStyle.STY_Alpha;

		// Draw Weird cam
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.DrawColor.A = 64;
		C.SetPos(0,0);
		C.DrawColor	= class'HUD_Assault'.static.GetTeamColor( Team );
        // Draw Reticle around visible vehicles
		foreach DynamicActors(class'Vehicle', V )
		{

			if ((V==Self)                   // is you
                || (V.Health < 1)             // health 0
                || V.bDeleteMe                // is asking for delete
                || V.GetTeamNum() == Team     // your team

                || V.bCanFly==false          // not being driven
                || !V.IndependentVehicle()
                 )     // not independant?
                 continue;


			if (!class'HUD_Assault'.static.IsTargetInFrontOfPlayer( C, V, ScreenPos, Location, Rotation ) )	continue;


            C.SetDrawColor(255, 0, 0, 192);

			C.Font = class'HudBase'.static.GetConsoleFont( C );

			VehicleInfoString = V.VehicleNameString $ ":" @ int(VSize(Location-V.Location)*0.01875.f) $ class'HUD_Assault'.default.MetersString;

            class'HUD_Assault'.static.Draw_2DCollisionBox( C, V, ScreenPos, VehicleInfoString, 1.5f, true );

        }

    if (Weapon.IsA('Weapon_WeaponPhantomX')){
       DrawTargetting( C );
    }else{
       Log("WumpusASVehicleAir:DrawVehicleHUD can't draw targeting - "$string(Weapon));
    }


		if(bStallSpeedLightOn) DrawStall( C, PC.myHUD );

}
*/


simulated function 	DrawStall( Canvas C, HUD H )
{
  local string StallMessage;
  local float		XL, YL;
  local float		XO, YO;
  local float		TexScale;
              //Left Right    Up Down
              //XL 53          YL 10
	TexScale = 1;
	C.Style = ERenderStyle.STY_Alpha;
	C.drawColor.R = 255;
    XL = 120 * TexScale * H.ResScaleX * H.HUDScale;
    YL = 84 * TexScale * H.ResScaleY * H.HUDScale;
    XO = C.ClipX - 57 * TexScale * H.ResScaleX * H.HUDScale;
    YO = C.ClipY - 63 * TexScale * H.ResScaleY * H.HUDScale;

    C.Font = class'HudBase'.static.GetConsoleFont( C );
    C.Style = ERenderStyle.STY_Translucent;
    StallMessage = "STALL WARNING !!";
    C.SetPos( XO - XL*0.5, YO - YL*0.5 );
    C.drawColor.R = 255;
    C.DrawText(StallMessage);
}


/* Space Fighter Targetting HUD code */
/*
simulated function 	DrawTargetting( Canvas C )
{
	local int XPos, YPos;
	local vector ScreenPos;
	local float RatioX, RatioY;
	local float tileX, tileY;
	local float SizeX, SizeY, PosDotDir;
	local vector CameraLocation, CamDir;
	local rotator CameraRotation;

    if (Weapon_PhantomBase(weapon).bLockedOn==true)
    {
       if(Weapon_PhantomBase(weapon).SeekTarget == None){
           return;
       }else{
           log("WumpusASVehicleAir:DrawTargeting - Weapon_PhantomBase Can't seekTarget");
           return;
       }


       C.DrawColor = CrosshairColor;
       C.DrawColor.A = 255;
       C.Style = ERenderStyle.STY_Alpha;

    SizeX = 30.0;
	SizeY = 30.0;

	ScreenPos = C.WorldToScreen( Weapon_PhantomBase(weapon).SeekTarget.Location );

	// Dont draw reticule if target is behind camera
	C.GetCameraLocation( CameraLocation, CameraRotation );
	CamDir = vector(CameraRotation);
	PosDotDir = (Weapon_PhantomBase(weapon).SeekTarget.Location - CameraLocation) dot CamDir;
	if( PosDotDir < 0)
		return;

	RatioX = C.SizeX / 640.0;
	RatioY = C.SizeY / 480.0;

	tileX = sizeX * RatioX;
	tileY = sizeY * RatioX;

	XPos = ScreenPos.X;
	YPos = ScreenPos.Y;

    C.DrawColor = CrosshairColor;
	C.DrawColor.A = 255;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
	C.DrawTile( CrosshairTexture, tileX, tileY, 0.0, 0.0, 128, 128); //--- TODO : Fix HARDCODED USIZE
    }

}
*/


simulated function DrawSpeedMeter( Canvas C, HUD H, PlayerController PC )
{
	local float		XL, YL, XL2, YL2, YOffset, XOffset, SpeedPct;

	C.Style = ERenderStyle.STY_Alpha;

	XL = 256 * 0.5 * H.ResScaleX * H.HUDScale;
	YL =  64 * 0.5 * H.ResScaleY * H.HUDScale;

	// Team color overlay
	C.DrawColor = class'HUD_Assault'.static.GetTeamColor( Team );
	C.SetPos( (C.ClipX - XL) * 0.5, C.ClipY - YL );
	C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Grey', XL, YL, 0, 0, 256, 64);

	// Speed Bar
	SpeedPct = DesiredVelocity - EngineMinVelocity;
	SpeedPct = FClamp( SpeedPct / (1000.f - EngineMinVelocity), 0.f, 1.f );
	XOffset =  1 * 0.5 * H.ResScaleX * H.HUDScale;
	YOffset = 27 * 0.5 * H.ResScaleY * H.HUDScale;
	XL2		= 84 * 0.5 * H.ResScaleY * H.HUDScale;
	YL2		= 18 * 0.5 * H.ResScaleX * H.HUDScale;

	C.DrawColor = class'HUD_Assault'.static.GetGYRColorRamp( SpeedPct );
	C.DrawColor.A = 96;

	C.SetPos( (C.ClipX - XL2) * 0.5 - XOffset, C.ClipY - YOffset - YL2 * 0.5 );
	C.DrawTile(Texture'InterfaceContent.WhileSquare', XL2*SpeedPct, YL2, 0, 0, 8, 8);

	// Solid Background
	C.DrawColor = class'Canvas'.Static.MakeColor(255, 255, 255);
	C.SetPos( (C.ClipX - XL) * 0.5, C.ClipY - YL );
	C.DrawTile(SpeedInfoTexture, XL, YL, 0, 0, 256, 64);
}



// MERGE 1
simulated function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector			CamLookAt, HitLocation, HitNormal;
	local PlayerController	PC;
	local float				CamDistFactor;
	local vector			CamDistance;
	local Rotator			CamRotationRate;
	local Rotator			TargetRotation;

	PC = PlayerController(Controller);

	// Only do this mode if we have a playercontroller viewing this vehicle
	if ( PC == None || PC.ViewTarget == None )
		return false;

	ViewActor = Self;

	if ( !PC.bBehindView )	// First Person View
	{
		SpecialCalcFirstPersonView( PC, ViewActor, CameraLocation, CameraRotation);
		return true;
	}

	// 3rd person view
	myDeltaTime			= Level.TimeSeconds - LastTimeSeconds;
	LastTimeSeconds		= Level.TimeSeconds;
	CamLookAt			= ViewActor.Location + (Vect(60, 0, 0) >> ViewActor.Rotation);

	// Camera Rotation
	if ( ViewActor == Self ) // Client Hack to camera roll is not affected by strafing
		TargetRotation = GetViewRotation();
	else
		TargetRotation = ViewActor.Rotation;

	if ( IsInState('ShotDown') )		// shotdown
	{
		TargetRotation.Yaw += 56768;
		Normalize( TargetRotation );
		CamRotationInertia = default.CamRotationInertia * 10.f;
		CamDistFactor	= 1024.0;

	}
	else if ( IsInState('Dying') )	// dead
	{
		CamRotationInertia = default.CamRotationInertia * 50.f;
		CamDistFactor	= 3.0;
	}
	else
	{
		CamDistFactor	= 1 - (DesiredVelocity / AirSpeed);
	}

	CamRotationRate			= Normalize(TargetRotation - LastCamRot);
	CameraRotation.Yaw		= CalcInertia(myDeltaTime, CamRotationInertia, CamRotationRate.Yaw, LastCamRot.Yaw);
	CameraRotation.Pitch	= CalcInertia(myDeltaTime, CamRotationInertia, CamRotationRate.Pitch, LastCamRot.Pitch);
	CameraRotation.Roll		= CalcInertia(myDeltaTime, CamRotationInertia, CamRotationRate.Roll, LastCamRot.Roll);
	LastCamRot				= CameraRotation;


	// Camera Location
	CamDistance		= Vect(-612, 0, 128);
	CamDistance.X	-= CamDistFactor * 200.0;	// Adjust Camera location based on ship's velocity
	CameraLocation	= CamLookAt + (CamDistance >> CameraRotation);

	if ( Trace( HitLocation, HitNormal, CameraLocation, ViewActor.Location, false, vect(10, 10, 10) ) != None )
		CameraLocation = HitLocation + HitNormal * 10;

	return true;
}

simulated function DrawHUD(Canvas C){

    local PlayerController PC;

    super.DrawHUD(C);

//    DrawTargetting( C );

    PC = PlayerController(Controller);
    if ( (PC == None) || (PC.ViewTarget == None) ){
        return;
    }

    // All of the special view stuff!!!!
    DrawSpeedMeter( C, PC.myHUD, PC );
    DrawVehicleHUD( C, PC );

}


//////////////////////
// END HUD
//////////////////////


///////////////////////
// State Changes
//////////////////////


simulated function TakeOff(){

    DesiredVelocity = EngineMinVelocity + 260;
    Velocity = EngineMinVelocity * Vector(Rotation);
    Acceleration = Velocity;
    bLanded = False;
    bReadyForTakeOff = True;
    bGearUp = True;
    PlayAnim('GearsUp');

    if ( LaunchSound != None )
    {
        PlaySound(LaunchSound, SLOT_None, 2.0);
    }

}


function PossessedBy(Controller C)
{
	super.PossessedBy(C);

    if (Role==ROLE_Authority)
    {
        AirSpeed=LaunchSpeed;
        AccelRate=2000.000000;
    }
}
/* MERGE
function PossessedBy (Controller C)
{
  Super.PossessedBy(C);

   if(true==true)
  {
    AirSpeed = 2800.0;
    AccelRate = 1200.0;
    //bLanded = False;
//    bReadyForTakeOff = True;
//    bGearUp = False;
//    PlayAnim(LandingGearsUp);
//    Velocity.X=1000.0;
//    Velocity.Y=1000.0;
//    Velocity.Z=1000.0;
  } else {
    AirSpeed = 3000.0;
    AccelRate = 2000.0;
  }
}
*/




simulated event DrivingStatusChanged()
{
    local PlayerController PC;

	PC = Level.GetLocalPlayerController();

	if (bDriving && PC != None && (PC.ViewTarget == None || !(PC.ViewTarget.IsJoinedTo(self))))
        bDropDetail = (Level.bDropDetail || (Level.DetailMode == DM_Low));
    else
        bDropDetail = False;

    if (bDriving)
       {
       	EngineIgnite();
        Enable('Tick');
       }
    else
      {
        EngineShutDown();
        Disable('Tick');
      }
}


simulated event TeamChanged()
{
     // Add Trail FX
	if ( Level.NetMode != NM_DedicatedServer )
	{
		SetTrailFX();
		SetRunningLightsFX();
		AdjustFX();
	}

}



function BlowUp( vector HitNormal )		// Blow up space ship
{
        Explode( Location, HitNormal );
		GotoState('Dying');
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	super.ClientKDriverEnter( PC );

}

// Called from the PlayerController when player wants to get out.
function bool KDriverLeave( bool bForceLeave )
{
   local Controller C;
   local Pawn		OldPawn;
   local vector	EjectVel;

	OldPawn = Driver;

      C = Controller;
	  C.StopFiring();
      if ( Super.KDriverLeave(bForceLeave) || bForceLeave )
         {
    	  if (C != None)
    	     {
	       	  C.Pawn.bSetPCRotOnPossess = C.Pawn.default.bSetPCRotOnPossess;
              Instigator = C.Pawn;  //so if vehicle continues on and runs someone over, the appropriate credit is given
             }
           EjectVel	= Velocity;
           if (bReadyForTakeOff==True)
	       EjectVel.Z	= EjectVel.Z + EjectMomentum;

	       OldPawn.Velocity = EjectVel;

            return True;
          }
        else
         return False;
}


simulated function Landed( vector HitNormal )
{
     SetPhysics(PHYS_none);
     bLanded=true;
     bReadyForTakeOff=false;
}


///////////////////////
// END State Changes
//////////////////////


///////////////////////
// Flying
//////////////////////



function bool CanAttack(Actor Other)
{
    // check that can see target
    if ( Controller != None )
		return Controller.LineOfSightTo(Other);
    return false;
}

//=
// Movement
//=
simulated function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange)
{
	local vector	X,Y,Z;
	local float		CurrentSpeed;
	local float		EngineAccel;
	local float		RotationSmoothFactor;
	local float		RollChange;
	local Rotator	NewRotation;

    //-----------------------------------
	if ( !bPostNetCalled || Controller == None )
		return;

	if ( !bInitialized  )
	{
		// Laurent -- Velocity Override
		// When Player Spawns with the spaceship as Pawn, velocity is reset at start match
		// since Rotation is overwritten later by Rotator(Velocity), it gets reset to Rotation(0,0,0)
		// And therefore not using the one set in PlayerStart.Rotation
		Acceleration = EngineMinVelocity * Vector(Rotation);
		SpaceFighterRotation = QuatFromRotator( Rotation );
		bInitialized = true;
	}

	// Only allow space fighter to change gear once landing gear is up.
	// (small hack for fins animations)
	if ( bGearUp )
		DesiredVelocity	= FClamp( DesiredVelocity+PlayerController(Controller).aForward*DeltaTime/15.f,EngineMinVelocity, AirSpeed);

	else
		DesiredVelocity	= EngineMinVelocity;

	CurrentSpeed	= FClamp( (Velocity dot Vector(Rotation)) * 1000.f / AirSpeed, 0.f, AirSpeed);
	EngineAccel		= (DesiredVelocity - CurrentSpeed) * 100.f;

	RotationSmoothFactor = FClamp(1.f - RotationInertia * DeltaTime, 0.f, 1.f);

	if ( PlayerController(Controller).bDuck > 0 && Abs(Rotation.Roll) > 500 )
	{
		// Auto Correct Roll
		if ( Rotation.Roll < 0 )
			RollChange = RollAutoCorrectSpeed;
		else
			RollChange = -RollAutoCorrectSpeed;
	}
	    //No Roll till takeoff
	   if (bReadyForTakeOff==True)
	      {
  	      //Barrel Roll Right
  	    if ( PlayerController(Controller).aStrafe > 0 ) // Rolling
  	       {
  		     if(Health < HealthMax / 3) //Damage makes it hard to control
               {
               if ( FRand() < 0.75 )
                  RollChange = PlayerController(Controller).aStrafe * 0.12;
               else
                  RollChange = PlayerController(Controller).aStrafe * 0.33;
               }
             else
              RollChange = PlayerController(Controller).aStrafe * 0.66;
           }
         //Barrel Roll Left
        if ( PlayerController(Controller).aStrafe < 0 ) // Rolling
  		   {
  		     if(Health < HealthMax / 2.5) //Damage makes it hard to control
               {
               if ( FRand() < 0.65 )
                  RollChange = PlayerController(Controller).aStrafe * 0.12;
               else
                  RollChange = PlayerController(Controller).aStrafe * 0.33;
              }
             else
              RollChange = PlayerController(Controller).aStrafe * 0.66;
           }


          }
    // Rotation Acceleration
	if (Controller.IsA('PlayerController'))
	   {
        if(Health < HealthMax / 2.5) //Damage makes it hard to control
          {
            if ( FRand() < 0.75 )
           YawAccel = (1-2*DeltaTime)*YawAccel + DeltaTime*VehicleYawRotSpeed*YawChange /10;
            else
            YawAccel = (1-2*DeltaTime)*YawAccel + DeltaTime*VehicleYawRotSpeed*YawChange;

          }
        else
        YawAccel = (1-2*DeltaTime)*YawAccel + DeltaTime*VehicleYawRotSpeed*YawChange;

       }
     else
        YawAccel	= RotationSmoothFactor*YawAccel   + DeltaTime*VehicleYawRotSpeed*YawChange;

     if (Controller.IsA('PlayerController'))
        {
         if (bReadyForTakeOff==True)
         {
           if(Health < HealthMax / 2.5)//Damage makes it hard to control
            {
            if ( FRand() < 0.75 )
            PitchAccel = (1-2*DeltaTime)*PitchAccel + DeltaTime*VehiclePitchRotSpeed*PitchChange /10;
            else
            PitchAccel = (1-2*DeltaTime)*PitchAccel + DeltaTime*VehiclePitchRotSpeed*PitchChange;

           }
           else
           PitchAccel = (1-2*DeltaTime)*PitchAccel + DeltaTime*VehiclePitchRotSpeed*PitchChange;
        }
      }
     else
         PitchAccel	= RotationSmoothFactor*PitchAccel + DeltaTime*VehiclePitchRotSpeed*PitchChange;

    RollAccel	= RotationSmoothFactor*RollAccel  + DeltaTime*VehicleRotationSpeed*RollChange;

	YawAccel	= FClamp( YawAccel, -AirSpeed, AirSpeed );
	PitchAccel	= FClamp( PitchAccel, -AirSpeed, AirSpeed );
	RollAccel	= FClamp( RollAccel, -AirSpeed, AirSpeed );

	// Perform new rotation
	GetAxes( QuatToRotator(SpaceFighterRotation), X, Y, Z );
	SpaceFighterRotation = QuatProduct(SpaceFighterRotation,
								QuatProduct(QuatFromAxisAndAngle(Y, DeltaTime*PitchAccel),
								QuatProduct(QuatFromAxisAndAngle(Z, -1.0 * DeltaTime * YawAccel),
								QuatFromAxisAndAngle(X, DeltaTime * RollAccel))));

	NewRotation = QuatToRotator( SpaceFighterRotation );

	// If autoadjusting roll, clamp to 0
	if ( PlayerController(Controller).bDuck > 0 && ((NewRotation.Roll < 0 && Rotation.Roll > 0) || (NewRotation.Roll > 0 && Rotation.Roll < 0)) )
	{
		NewRotation.Roll = 0;
		RollAccel = 0;
	}

    if(Health < HealthMax / 2)//Damage makes it hard to control
      {
       if ( FRand() < 0.75 )
	    Acceleration = Vector(NewRotation) * DesiredVelocity /1.4;
	   else
	    Acceleration = Vector(NewRotation) * DesiredVelocity;
      }
    else
      Acceleration = Vector(NewRotation) * DesiredVelocity;

    if(bReadyForTakeOff==true && bLanded==false)
	 {
     if (DesiredVelocity <= EngineMinVelocity+200)
      {
		velocity.z=-200.0;
        Acceleration.Z =-200.0;
      }

     }

    // Adjust Rolling based on Stafing
	NewRotation.Roll += StrafeAccel * 15;

	// Take complete control on Rotation
	bRotateToDesired	= true;
	bRollToDesired		= true;
	DesiredRotation		= NewRotation;
	SetRotation( NewRotation );

	if(bLanded ==true)
      {
        MinFlySpeed=LandingSpeed;
        EngineMinVelocity=LandingEngineMinVelocity;
        DesiredVelocity=LandingEngineMinVelocity;

        DeathSpiral.Yaw=Rotation.Yaw;
	    DeathSpiral.pitch=0;//Rotation.Pitch;
	    DeathSpiral.Roll = 0;//Rotation.Roll;
      	bRotateToDesired	= true;
       	bRollToDesired		= true;

        DesiredRotation = DeathSpiral;
        SetRotation(DeathSpiral);
      }
}


///////////////////////
// END Flying
//////////////////////

//////////////////////
// Collision
//////////////////////

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    log("TakeDamage");

	if ( instigatedBy == None || bLanded==true){
        log("Wall");
	    bDamageHitWall=true;  // hit wall
    }
	else if ( instigatedBy == self || (instigatedBy == self && bLanded==true) ){
        log("Suicide");
	    bDamageByPlayer=true; // suicide
    } else {
        log("Enemy Fire");
		bDamageByPlayer=true; // killed by player
	}

	super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

}


simulated function VehicleCollision(Vector HitNormal, Actor Other)
{
	local float		CollisionDamage;
	local float		NormalSpeed;
	local Pawn		Inst;

    log("VehicleCollision");

	if ( Role < Role_Authority )
		return;

	NormalSpeed = Abs( Velocity dot HitNormal );
	CollisionDamage		= (NormalSpeed-200) / 100.0;

	if ( Damage > 1.f )
	{
		CollisionDamage *= CollisionDamage;
        Inst = Pawn(Other);
        TakeDamage(CollisionDamage, Inst, Location-HitNormal*CollisionRadius, HitNormal*Damage*100.f,class'DamType_AirRoadkill');
//XXX         if (ImpactDamageSounds.Length > 0)
//XXX 		PlaySound(ImpactDamageSounds[Rand(ImpactDamageSounds.Length-1)],,TransientSoundVolume*3.5);
    }
	else if ( VSize(Velocity) < 100 )
		TakeDamage(default.Health*2, Self, Location, vect(0,0,0),class'DamType_AirRoadkill');
}



simulated function HitWall(vector HitNormal, actor Wall)
{
    if (Controller==none){
        bDamageHitWall=true;
        BlowUp( vect(0,0,1));
        TakeDamage(default.Health*2, Self, Location, vect(0,0,0), None);
    }

    // if not Landing Take Damage
    if ( VSize(Velocity) < 800 ){     // <- landed speed?
        bLanded =true;
        bReadyForTakeOff=false;
        return;
    } else {
        VehicleCollision(HitNormal, Wall);
    }
}

simulated singular function Touch(Actor Other)
{
    log("Touch");
    CheckContact(Other);
}

simulated function Bump( Actor Other )
{
    log("Bump");
    if (Role==ROLE_Authority) {
        CheckContact(Other);
    }
}

simulated function CheckContact(Actor Other){
    local Vector HitNormal;

    if(Other!=None){

        if (Other.IsA('xPawn') && xPawn(other).PlayerReplicationInfo.Team.TeamIndex!=Team){
            // TO-DO Hit teammate
            log("Hit teammate");
            return;
        }

	    if (Other.IsA('Vehicle')) {
            log("Hit Vehicle");
	        if(VSize(Velocity) > 100){
                log("High Velocity");
                Vehicle(other).TakeDamage(1000, Self, Location, vect(0,0,0), class'DamType_AirRoadkill');
	            BlowUp( vect(0,0,1));
                TakeDamage(default.Health*2, Self, Location, vect(0,0,0),class'DamType_AirRoadkill');
                return;
            } else {
                log("Low Velocity");
                // TO-DO Hit Vehicle with landing speed, Damage & Land?
            }
        }

        if(Other.IsA('xPawn')){
            log("Hit xPawn");
            xPawn(other).TakeDamage(1000, Self, Location, vect(0,0,0), class'DamType_AirRoadkill');
            return;
        }


        if (!Other.IsA('Projectile') && Other.bBlockActors ) {
            log("Other");
	        HitNormal = Normal(Location - Other.Location);
		    VehicleCollision(HitNormal, Other);
        }

    }
}

//////////////////////
// END Collision
//////////////////////



//=============================================================================
// FX
//=============================================================================

event AnimEnd( int Channel )
{
	Disable('AnimEnd');
	bGearUp = true;
}


simulated function Destroyed()
{
	if ( Thruster != None )   Thruster.Destroy();

	if (LeftWingLight!=none)  LeftWingLight.Destroy();

    if (RightWingLight!=none) RightWingLight.Destroy();

    if (BottomLight!=none)    BottomLight.Destroy();

    if ( SmokeTrail != None ) SmokeTrail.Destroy();

    if( DamageSmoke!=none)    DamageSmoke.Destroy();


    if (Role==ROLE_Authority) {

    	if ( Thruster != None )   Thruster.Destroy();

	    if (LeftWingLight!=none)  LeftWingLight.Destroy();

        if (RightWingLight!=none) RightWingLight.Destroy();

        if (BottomLight!=none)    BottomLight.Destroy();

        if ( SmokeTrail != None ) SmokeTrail.Destroy();

        if( DamageSmoke!=none)    DamageSmoke.Destroy();
	}
	super.Destroyed();
}

simulated function AdjustFX()
{
	local float			NewSpeed, VehicleSpeed, SpeedPct;
	local int			i, averageOver;

	// Smooth filter on velocity, which is very instable especially on Jerky frame rate.
	NewSpeed = Max(Velocity Dot Vector(Rotation), EngineMinVelocity);
	SpeedFilter[NextSpeedFilterSlot] = NewSpeed;
	NextSpeedFilterSlot++;

	if ( bSpeedFilterWarmup )
		averageOver = NextSpeedFilterSlot;
	else
		averageOver = SpeedFilterFrames;

	for (i=0; i<averageOver; i++)
		VehicleSpeed += SpeedFilter[i];

	VehicleSpeed /= float(averageOver);

	if ( NextSpeedFilterSlot == SpeedFilterFrames ) {
		NextSpeedFilterSlot = 0;
		bSpeedFilterWarmup	= false;
	}

	SmoothedSpeedRatio = VehicleSpeed / AirSpeed;
	SpeedPct = VehicleSpeed - EngineMinVelocity*AirSpeed/1000.f;
	SpeedPct = FClamp( SpeedPct / (AirSpeed*( (1000.f-EngineMinVelocity)/1000.f )), 0.f, 1.f );

	UpdateEngineSound( SpeedPct );

	// Adjust FOV depending on speed
	if ( PlayerController(Controller) != None && IsLocallyControlled() )
		PlayerController(Controller).SetFOV( PlayerController(Controller).DefaultFOV + SpeedPct*SpeedPct*15  );
}

simulated function UpdateEngineSound( float SpeedPct )
{
	// Adjust Engine volume
	SoundVolume = 180 +  32 * SpeedPct;
	SoundPitch	=  86 +  16 * SpeedPct;
}

simulated function Timer()
{
	local float			NewTimerRate;

	if (Role==ROLE_Authority)
    {
	 AdjustFX();
	// Update Frequency (for super High details)
	if ( IsLocallyControlled() )
		NewTimerRate = 0.02;
	else if ( EffectIsRelevant(Location, false) ) // if this pawn is relevant to local player
		NewTimerRate = 0.04;
	else
		NewTimerRate = 0.08;		// Not relevant

	SetTimer(NewTimerRate, true);
  }
}

simulated final function MyRandSpin(float spinRate)
{
   //stop landed planes from turning when destroyed
   if(bLanded ==true)
     return;

       if(bDeathRotation==false)
          DeathRotation = Rand(DeathSpiralRotation.Length);
     if(DeathRotation==0)
       {
        bDeathRotation=true;
        DeathSpiral.Yaw=Rotation.Yaw + 20;
	    DeathSpiral.pitch=Rotation.Pitch - 30;
	    DeathSpiral.Roll = Rotation.Roll + 500;
       }
     if(DeathRotation==1)
       {
        bDeathRotation=true;
        DeathSpiral.Yaw=Rotation.Yaw + 300;
	    DeathSpiral.pitch=Rotation.Pitch - 30;
	    DeathSpiral.Roll = Rotation.Roll - 500;
       }

     if(DeathRotation==2)
       {
        bDeathRotation=true;
        DeathSpiral.Yaw=Rotation.Yaw + 0;
	    DeathSpiral.pitch=Rotation.Pitch - 500;
	    DeathSpiral.Roll = Rotation.Roll + 200;
       }
     SetRotation(DeathSpiral);
}

// Spawn Explosion FX
simulated function Explode( vector HitLocation, vector HitNormal )
{
	if ( SmokeTrail != None )
	{
		SmokeTrail.Kill();
		SmokeTrail = None;
	}
	if ( Thruster != None )
	     Thruster.Destroy();
	if (LeftWingLight!=none)
        LeftWingLight.Destroy();
    if (RightWingLight!=none)
        RightWingLight.Destroy();
    if (BottomLight!=none)
        BottomLight.Destroy();
	bDynamicLight = false;
	LightType = LT_None;

	if ( Role == ROLE_Authority )
	{
	 if ( Thruster != None )
	    Thruster.Destroy();
	 if (LeftWingLight!=none)
         LeftWingLight.Destroy();
     if (RightWingLight!=none)
         RightWingLight.Destroy();
     if (BottomLight!=none)
         BottomLight.Destroy();
     }
    if ( Level.NetMode != NM_DedicatedServer )
	    {
         if(bLanded==false)
//(xyz)	         ExplosionEffect= Spawn(ExplosionEffectClass, Self,, HitLocation, Rotation);
         HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
//         PlaySound(sound'W_Dragon-SD.NKRadExp',SLOT_None,2.5);
//         Spawn(class'APVerIV.FX_NukeFlashFirst',,, Location, Rotation);
//         Spawn(class'APVerIV.FX_NukeFlash',,, Location, Rotation);
//         Spawn(class'APVerIV.FX_MissileHitGlow',,, Location, Rotation);
//         PlaySound(sound'APVerIV_Snd.NKExp',SLOT_None,2.5);
        }
}

function DriverDied()
{
  TakeDamage(default.Health*2, Self, Location, vect(0,0,0), None);

}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local vector	HitNormal;

	if ( Level.Game != None )
		Level.Game.DiscardInventory( Self );
     if ( PlayerController(Controller) != none)
           PlayerController(Controller).StopViewShaking();
	// Make sure player controller is actually possessing the vehicle.. (since we forced it in ClientKDriverEnter)
	if ( PlayerController(Controller) != None && PlayerController(Controller).Pawn != Self )
		Controller = None;

	if ( PlayerController(Controller) != None )
	{
		PlayerController(Controller).SetViewTarget( Self );

	}

	bCanTeleport = false;
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;

	if ( HitFxTicker == 2 )
	{
		if ( Level.NetMode != NM_DedicatedServer )
		{
			SmokeTrail = Spawn(ShotDownFXClass, Self,, Location);
			if ( SmokeTrail != None )
				SmokeTrail.SetBase( self );
		}
		GotoState('ShotDown');
	}
	else
	{
		if ( HitFxTicker == 0 )
			HitNormal = Normal( TearOffMomentum );	// Set Directional explosion based on HitNormal

		Explode( Location, HitNormal );
		GotoState('Dying');
	}
}

///////////////////////
// STATE: Shot down in flames
//////////////////////
state ShotDown
{
	ignores Trigger, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, name FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}
	event FellOutOfWorld(eKillZType KillType) {	}
	function ReduceCylinder() { }
	function LandThump() {	}
	event AnimEnd(int Channel) {	}
	function LieStill() {}
	singular function BaseChange() {	}
	function Died(Controller Killer, class<DamageType> damageType, vector HitLocation) {}
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType) {}

	function VehicleSwitchView(bool bUpdating) {}
	function DriverDied();
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);

	function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange);


	simulated function Timer()
	{
		BlowUp( vect(0,0,0) );
	}

	// Blow up Space Fighter
	simulated function BlowUp( vector HitNormal )
	{
		Explode( Location, HitNormal );
		GotoState('Dying');
	}

    simulated function BeginState()
	{
		local PlayerController	PC;

		Acceleration.Z -= VSize(Velocity)*0.67;
		PC = PlayerController(Controller);
		if(controller!=none)
		  {
           DamMomentum=0;
		   Controller.DamageShake(DamMomentum);
          }
        if ( PC != None && !PC.bBehindView )
		   {
			PC.bBehindView = true;// Force Behindview
            PC.StopViewShaking();
           }
		if ( Driver != None && bDrawDriverInTP )
			Destroyed_HandleDriver();

		if ( Controller != None )
			Controller.PawnDied( self );
	}

	simulated function EndState()
	{
		AmbientSound	= None;
		bDynamicLight	= false;
		LightType		= LT_None;
	}

Begin:
	SetTimer(4.0, false);
}

///////////////////////
// END - STATE: Shot down in flames
//////////////////////

///////////////////////
// Effects
//////////////////////



simulated function EngineIgnite()
{
  if (Role==Role_Authority)
     {
      if ( Thruster != none)
       Thruster.SetVisable();

  if ( RightWingLight != none )
       RightWingLight.SetVisable();
  if ( LeftWingLight != none )
       LeftWingLight.SetVisable();
  if ( BottomLight != none )
       BottomLight.SetVisable();
       }
  if ( Thruster != none)
       Thruster.SetVisable();

  if ( RightWingLight != none )
       RightWingLight.SetVisable();
  if ( LeftWingLight != none )
       LeftWingLight.SetVisable();
  if ( BottomLight != none )
       BottomLight.SetVisable();
}


simulated function EngineShutDown()
{
   if (Role==Role_Authority)
       {
         if (Thruster!= none)
       Thruster.SetInvisable();

   if ( RightWingLight != none )
        RightWingLight.SetInvisable();
   if ( LeftWingLight != none )
        LeftWingLight.SetInvisable();
   if ( BottomLight != none )
        BottomLight.SetInvisable();
    }
   if (Thruster!= none)
       Thruster.SetInvisable();

   if ( RightWingLight != none )
        RightWingLight.SetInvisable();
   if ( LeftWingLight != none )
        LeftWingLight.SetInvisable();
   if ( BottomLight != none )
        BottomLight.SetInvisable();
}

simulated function SetTrailFX ()
{
  if ( (Thruster == None) && (Health > 0) && (Team != 255) )
  {
    Thruster = Spawn(Class'FX_PhantomXThrusters',self);
    Thruster.SetBase(self);
    AttachToBone(Thruster,'MidEngine');
  }
  if ( (Thruster != None) && ((Team == 0) || (Controller != None) && (Controller.PlayerReplicationInfo.Team.TeamIndex == 0)) )
  {
    Thruster.SetRedColor();
  }
  if ( (Thruster != None) && ((Team == 1) || (Controller != None) && (Controller.PlayerReplicationInfo.Team.TeamIndex == 1)) )
  {
    Thruster.SetBlueColor();
  }
}

simulated function SetRunningLightsFX ()
{
  if ( (LeftWingLight == None) && (Health > 0) && (Team != 255) )
  {
    LeftWingLight = Spawn(Class'FX_RunningLight',self,,Location);
    AttachToBone(LeftWingLight,'LWLight');
    RightWingLight = Spawn(Class'FX_RunningLight',self,,Location);
    AttachToBone(RightWingLight,'RWLight');
    BottomLight = Spawn(Class'FX_RunningLight',self,,Location);
    AttachToBone(BottomLight,'BLight');
  }
  if ( LeftWingLight != None )
  {
    if ( (Team == 1) || (Controller != None) && (Controller.PlayerReplicationInfo.Team.TeamIndex == 1) )
    {
      LeftWingLight.SetBlueColor();
      RightWingLight.SetBlueColor();
      BottomLight.SetBlueColor();
    } else {
      if ( (Team == 0) || (Controller != None) && (Controller.PlayerReplicationInfo.Team.TeamIndex == 0) )
      {
        LeftWingLight.SetRedColor();
        RightWingLight.SetRedColor();
        BottomLight.SetRedColor();
      }
    }
  }
}

simulated function AdjustEngineFX ()
{
  local Vector FXAmount;
  local float CurrThrust;

  CurrThrust = FClamp( (Velocity dot Vector(Rotation)) * 1000.f / AirSpeed, 0.f, 1000.f);
  FXAmount.Z = 0.001 * CurrThrust;

  FXAmount.X = 1.12;
  FXAmount.Y = 1.0;

  if ( Thruster != None )
  {
    Thruster.SetDrawScale3D(FXAmount);

  }
}





simulated function Flyby()
{
    local vector TraceStart, TraceEnd, HitLocation, HitNormal;
	local actor HitActor;
    if(bflyby!=True)
      {
  if (FlybyCountdown <=0)
     {
       foreach RadiusActors(class'Pawn', FlybyPawn, FlybyRange, Location)
             {
                if (FlybyPawn.IsA('XPawn') && XPawn(FlybyPawn).Controller!=none)
                   {
                    TraceStart = Location + (FlybyOffset >> Rotation);
			        TraceEnd = TraceStart - ( FlybyTraceDistance * vect(1,0,1) );
                    TraceEnd=FlybyPawn.Location;
                    HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, True);
                    if(HitActor==FlybyPawn && (((FlybyPawn.Location.X - Location.x) <= FlybyTraceDistance) || ((FlybyPawn.Location.z - Location.z) <= FlybyTraceDistance)))
                       {
                        FlybyPawn.PlaySound(FlybySound, SLOT_None,200,true, 600);
                        FlybyCountdown = 0.0;
                        FlybyCountdown += FlybyInterval;
                        bflyby=true;
                       }
                    }
              }
      }
     }
}

//simulated function UpdateEngineSound(float SpeedPct);


///////////////////////
// END - Effects
//////////////////////

defaultproperties
{
     VehicleRotationSpeed=0.016000
     VehiclePitchRotSpeed=0.001500
     VehicleYawRotSpeed=0.001000
     RollAutoCorrectSpeed=3000.000000
     MenuYawSpeed=1.000000
     MenuPitchSpeed=1.500000
     MenuRollSpeed=16.000000
     RotationInertia=20.000000
     LaunchSpeed=2600.000000
     bSpeedFilterWarmup=True
     bLanded=True
     Damage=250.000000
     DamageRadius=1024.000000
     MomentumTransfer=6000.000000
     MyDamageType=Class'W_Phantom.DamType_AirRoadkill'
     SpeedInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid'
     CamRotationInertia=10.330000
     LandingGearsUp="GearsUp"
     LandingGearsDown="GearsDown"
     FlyingAnim="Flying"
     ShotDownFXClass=Class'UT2k4AssaultFull.FX_SpaceFighter_ShotDownEmitter'
     FlybyRange=3000.000000
     FlybySound=Sound'W_Dragon-SD.PhantomFlyby'
     Flybyoffset=(Z=-60.000000)
     FlybyInterval=6.500000
     FlybyTraceDistance=4000.000000
     LaunchSound=Sound'W_Dragon-SD.EnginesLightupA'
     DefaultWeaponClassName="W_Phantom.Weapon_Phantom"
     bHasRadar=True
     bCanCarryFlag=False
     EjectMomentum=2500.000000
     ExitPositions(0)=(X=-1024.000000,Z=256.000000)
     ExitPositions(1)=(X=-1024.000000,Z=256.000000)
     ExitPositions(2)=(X=-1024.000000,Z=256.000000)
     ExitPositions(3)=(X=-1024.000000,Z=256.000000)
     EntryPosition=(Z=-20.000000)
     EntryRadius=300.000000
     FPCamPos=(X=15.000000,Z=20.000000)
     CenterSpringForce="SpringSpaceFighter"
     CenterSpringRangePitch=0
     CenterSpringRangeRoll=0
     DriverDamageMult=0.000000
     VehiclePositionString="in a Phantom Fighter"
     VehicleNameString="Phantom Fighter"
     bCanFly=True
     bCanStrafe=True
     bSimulateGravity=False
     bDirectHitWall=True
     bServerMoveSetPawnRot=False
     bSpecialHUD=True
     bSpecialCalcView=True
     SightRadius=25000.000000
     AirSpeed=15000.000000
     AccelRate=2000.000000
     HealthMax=250.000000
     Health=300
     LandMovementState="PlayerSpaceFlying"
     MaxRotation=40.849998
     AmbientSound=Sound'AssaultSounds.HumanShip.HnSpaceShipEng01'
     Mesh=SkeletalMesh'W_Phantom-AN.PhantomMesh'
     DrawScale=1.300000
     AmbientGlow=86
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=784.000000
     CollisionHeight=68.000000
     RotationRate=(Pitch=32768,Yaw=32768,Roll=32768)
     ForceType=FT_DragAlong
     ForceRadius=100.000000
     ForceScale=5.000000
}
