//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Apache extends ONSChopperCraft
  Placeable
  Config(User);

var() float MaxPitchSpeed;
var() array<Vector> TrailEffectPositions;
var Class<Emitter_ApacheExhaust> TrailEffectClass;
var array<Emitter_ApacheExhaust> TrailEffects;
var() array<Vector> DNSparkEffectPositions;
var Class<Emitter_ApacheSparks> DNSparkEffectClass;
var array<Emitter_ApacheSparks> DNSparkEffects;
var() array<Vector> StreamerEffectOffset;
var Class<ONSAttackCraftStreamer> StreamerEffectClass;
var array<ONSAttackCraftStreamer> StreamerEffect;
var() Range StreamerOpacityRamp;
var() float StreamerOpacityChangeRate;
var() float StreamerOpacityMax;
var float StreamerCurrentOpacity;
var bool StreamerActive;
var float ControlLossFactor;
var() Sound BladeBreakSound;
var name TailBone;
var float CollOffset;


// Target locking
var	Vehicle		CurrentTarget;
var	float		MaxTargetingRange;
var	float		LastAutoTargetTime;
var	Vector		CrosshairPos;
var Sound		TargetAcquiredSound;

var Texture		WeaponInfoTexture, SpeedInfoTexture;
var Material CrosshairTexture;

var Sound	RocketLoadedSound;
var				bool	bAutoTarget;			// automatically target closest Vehicle
var				bool	bTargetClosestToCrosshair;
var				bool	bRocketLoaded;

var()	Vector		VehicleProjSpawnOffset;		// Projectile Spawn Offset
var	bool		bCHZeroYOffset;		// For dual cannons, just trace from the center.
var	Material	DefaultCrosshair, CrosshairHitFeedbackTex;
var float		CrosshairScale;

var	float		LastCalcWeaponFire;	// avoid multiple traces the same tick
var	Actor		LastCalcHA;
var	vector		LastCalcHL, LastCalcHN;
var vector BotError;
var Actor OldTarget;

var() HudBase.SpriteWidget HudMissileCount, HudMissileIcon;
var() HudBase.NumericWidget HudMissileDigits;
var() HudBase.DigitSet DigitsBig;

replication
{

	reliable if ( bNetDirty && bNetOwner && Role==ROLE_Authority )
		CurrentTarget;

	reliable if ( Role < ROLE_Authority )
		GetPreviousTarget, GetNextTarget, ServerSetTarget, GetBestTarget;
}

function Died (Controller Killer, Class<DamageType> DamageType, Vector HitLocation)
{
  local int i;

  if ( Level.NetMode != 1 )
  {

    for(i = 0; i < DNSparkEffects.Length; i++ )
    {
      DNSparkEffects[i].Destroy();
    }
    DNSparkEffects.Length = 0;


    for( i = 0;i < TrailEffects.Length;i++ )
    {
      TrailEffects[i].Destroy();
    }
    TrailEffects.Length = 0;
  }
  Super.Died(Killer,DamageType,HitLocation);
}

simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector CamLookAt, HitLocation, HitNormal, OffsetVector;
	local Actor HitActor;
    local vector x, y, z;

	if (DesiredTPCamDistance < TPCamDistance)
		TPCamDistance = FMax(DesiredTPCamDistance, TPCamDistance - CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));
	else if (DesiredTPCamDistance > TPCamDistance)
		TPCamDistance = FMin(DesiredTPCamDistance, TPCamDistance + CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));

    GetAxes(PC.Rotation, x, y, z);
	ViewActor = self;
	CamLookAt = GetCameraLocationStart() + (TPCamLookat >> Rotation) + TPCamWorldOffset;

	OffsetVector = vect(0, 0, 0);
	OffsetVector.X = -1.0 * TPCamDistance;

	CameraLocation = CamLookAt + (OffsetVector >> PC.Rotation);

	HitActor = Trace(HitLocation, HitNormal, CameraLocation, Location, true, vect(40, 40, 40));
	if ( HitActor != None
	     && (HitActor.bWorldGeometry || HitActor == GetVehicleBase() || Trace(HitLocation, HitNormal, CameraLocation, Location, false, vect(40, 40, 40)) != None) )
			CameraLocation = HitLocation;

    CameraRotation = Normalize(PC.Rotation + PC.ShakeRot);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}


simulated function Destroyed ()
{
  local int i;

  if ( Level.NetMode != 1 )
  {
    for(i = 0; i < DNSparkEffects.Length; i++ )
    {
      DNSparkEffects[i].Destroy();
    }
    DNSparkEffects.Length = 0;


    for( i = 0;i < TrailEffects.Length;i++ )
    {
      TrailEffects[i].Destroy();
    }
    TrailEffects.Length = 0;
  }
  Super.Destroyed();
}

simulated event DrivingStatusChanged ()
{
  local Vector RotX;
  local Vector RotY;
  local Vector RotZ;
  local int i;

  Super.DrivingStatusChanged();
  if ( bDriving && (Level.NetMode != 1) &&  !bDropDetail )
  {
    GetAxes(Rotation,RotX,RotY,RotZ);
    if ( DNSparkEffects.Length == 0 )
    {
      DNSparkEffects.Length = DNSparkEffectPositions.Length;

      for (i = 0; i < DNSparkEffects.Length; i++ )
      {
        if ( DNSparkEffects[i] == none      )
        {
          DNSparkEffects[i] = Spawn(DNSparkEffectClass,self,,Location + (DNSparkEffectPositions[i] >> Rotation));
          DNSparkEffects[i].SetBase(self);
          DNSparkEffects[i].SetRelativeRotation(rot(0,32768,0));
          DNSparkEffects[i].StartSparks(False);
        }

      }
    }
    if ( TrailEffects.Length == 0 )
    {
      TrailEffects.Length = TrailEffectPositions.Length;

      for (i = 0; i < TrailEffects.Length; i++)
      {
        if ( TrailEffects[i] == None )
        {
          TrailEffects[i] = Spawn(TrailEffectClass,self,,Location + (TrailEffectPositions[i] >> Rotation));
          TrailEffects[i].SetBase(self);
          TrailEffects[i].SetRelativeRotation(rot(0,32768,0));
        }

      }
    }
  } else {
    if ( Level.NetMode != 1 )
    {

      for(i = 0; i < TrailEffects.Length; i++)
      {
        TrailEffects[i].Destroy();

      }
      TrailEffects.Length = 0;
    }
  }
}

function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, Class<DamageType> DamageType)
{
  Super.TakeDamage(Damage,instigatedBy,HitLocation,Momentum,DamageType);

}




simulated function Tick (float DeltaTime)
{
  local float EnginePitch;
  local float ThrustAmount;
  local int i;
  local Vector RelVel;
  local bool bIsBehindView;
  local PlayerController PC;


  LoopAnim('Flying',1.0);

  if ( Level.NetMode != 1 )
  {

    EnginePitch = 64.0 + VSize(Velocity) / MaxPitchSpeed * 32.0;
    SoundPitch = byte(FClamp(EnginePitch,64.0,96.0));
    RelVel = Velocity << Rotation;
    PC = Level.GetLocalPlayerController();
    if ( (PC != None) && (PC.ViewTarget == self) )
    {
      bIsBehindView = PC.bBehindView;
    } else {
      bIsBehindView = True;
    }
    if (  !bIsBehindView )
    {

      for (i = 0; i < TrailEffects.Length;i++ )
      {
        TrailEffects[i].SetThrustEnabled(False);
      }
    } else {
      ThrustAmount = FClamp(OutputThrust,0.0,1.0);
      for (i = 0; i < TrailEffects.Length;i++ )
      {
        TrailEffects[i].SetThrustEnabled(True);
        TrailEffects[i].SetThrust(ThrustAmount);
      }
    }
  }

  GetTarget();

  Super.Tick(DeltaTime);
}

function float ImpactDamageModifier ()
{
  local float Multiplier;
  local Vector X;
  local Vector Y;
  local Vector Z;

  GetAxes(Rotation,X,Y,Z);
  if ( ImpactInfo.impactNorm Dot Z > 0 )
  {
    Multiplier = 1.0 - ImpactInfo.impactNorm Dot Z;
  } else {
    Multiplier = 1.0;
  }
  return Super.ImpactDamageModifier() * Multiplier;
}

function bool RecommendLongRangedAttack ()
{
  return True;
}


/*
function bool PlaceExitingDriver ()
{
  local int i;
  local Vector tryPlace;
  local Vector Extent;
  local Vector HitLocation;
  local Vector HitNormal;
  local Vector ZOffset;

  Extent = Driver.Default.CollisionRadius * vect(1.00,1.00,0.00);
  Extent.Z = Driver.Default.CollisionHeight;
  Extent *= 2;
  ZOffset = Driver.Default.CollisionHeight * vect(0.00,0.00,1.00);
  if ( Trace(HitLocation,HitNormal,Location + ZOffset * 5,Location,False,Extent) != None )
  {
    return False;
  }
  if ( VSize(Velocity) > 100 )
  {
    tryPlace = Normal(Velocity Cross vect(0.00,0.00,1.00)) * (CollisionRadius + Driver.Default.CollisionRadius) * 1.25;
    if ( FRand() < 0.5 )
    {
      tryPlace *= -1;
    }
    if ( (Trace(HitLocation,HitNormal,Location + tryPlace + ZOffset,Location + ZOffset,False,Extent) == None) && Driver.SetLocation(Location + tryPlace + ZOffset) || (Trace(HitLocation,HitNormal,Location - tryPlace + ZOffset,Location + ZOffset,False,Extent) == None) && Driver.SetLocation(Location - tryPlace + ZOffset) )
    {
      return True;
    }
  }

  for ( i = 0; i < ExitPositions.Length ; i++)
  {
    if ( ExitPositions[0].Z != 0 )
    {
      ZOffset = vect(0.00,0.00,1.00) * ExitPositions[0].Z;
    } else {
      ZOffset = Driver.Default.CollisionHeight * vect(0.00,0.00,2.00);
    }
    if ( bRelativeExitPos )
    {
      tryPlace = Location + (ExitPositions[i] - ZOffset >> Rotation) + ZOffset;
    } else {
      tryPlace = ExitPositions[i];
    }
    if ( bRelativeExitPos && (Trace(HitLocation,HitNormal,tryPlace,Location + ZOffset,False,Extent) != None) )
    {
      //goto JL02CC;
    }
    if (  !Driver.SetLocation(tryPlace) )
    {
      //goto JL02CC;
    }
    return True;
  }
  return False;
}
*/
function bool PlaceExitingDriver()
{
	local int i;
	local vector tryPlace, Extent, HitLocation, HitNormal, ZOffset;

	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent *= 2;
	Extent.Z = Driver.default.CollisionHeight;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,1);
	if (Trace(HitLocation, HitNormal, Location + (ZOffset * 6), Location, false, Extent) != None)
		return false;

	//avoid running driver over by placing in direction perpendicular to velocity
	if ( VSize(Velocity) > 100 )
	{
		tryPlace = Normal(Velocity cross vect(0,0,1)) * (CollisionRadius + Driver.default.CollisionRadius ) * 1.25 ;
		if ( FRand() < 0.5 )
			tryPlace *= -1; //randomly prefer other side
		if ( (Trace(HitLocation, HitNormal, Location + tryPlace + ZOffset, Location + ZOffset, false, Extent) == None && Driver.SetLocation(Location + tryPlace + ZOffset))
		     || (Trace(HitLocation, HitNormal, Location - tryPlace + ZOffset, Location + ZOffset, false, Extent) == None && Driver.SetLocation(Location - tryPlace + ZOffset)) )
			return true;
	}

	for( i=0; i<ExitPositions.Length; i++)
	{
		if ( ExitPositions[0].Z != 0 )
			ZOffset = Vect(0,0,1) * ExitPositions[0].Z;
		else
			ZOffset = Driver.default.CollisionHeight * vect(0,0,2);

		if ( bRelativeExitPos )
			tryPlace = Location + ( (ExitPositions[i]-ZOffset) >> Rotation) + ZOffset;
		else
			tryPlace = ExitPositions[i];

		// First, do a line check (stops us passing through things on exit).
		if ( bRelativeExitPos && Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None )
			continue;

		// Then see if we can place the player there.
		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}



//
// HUD
//

simulated function DrawHUD (Canvas Canvas)
{
  local PlayerController PC;

  Super.DrawHUD(Canvas);
  if ( (Health < 1) || (Controller == None) || (PlayerController(Controller) == None) )
  {
    return;
  }
  PC = PlayerController(Controller);
  DrawVehicleHUD(Canvas,PC);

}

simulated function DrawVehicleHUD (Canvas C, PlayerController PC)
{
  local Vehicle V;
  local Vector ScreenPos;
  local string VehicleInfoString;
  local HudCDeathmatch H;


  C.Style = 5;
  C.DrawColor.R = 255;
  C.DrawColor.G = 255;
  C.DrawColor.B = 255;
  C.DrawColor.A = 64;
  C.SetPos(0.0,0.0);
  C.DrawColor = Class'UT2k4Assault.HUD_Assault'.static.GetTeamColor(Team);

  foreach DynamicActors(Class'Vehicle',V)
  {
//    if ( (V == self) || (V.Health < 1) || V.bDeleteMe || (V.GetTeamNum() == Team) || (V.bDriving == False) ||  !V.IndependentVehicle() )
    if ( IsTargetRelevant(V) )
    {

        if (  !Class'HUD_Assault'.static.IsTargetInFrontOfPlayer(C,V,ScreenPos,Location,Rotation) )
        {
          continue;
        } else {
          if (  !FastTrace(V.Location,Location) )
          {
            continue;
          } else {
            C.SetDrawColor(255,0,0,192);
            C.Font = Class'HudBase'.static.GetConsoleFont(C);
            VehicleInfoString = V.VehicleNameString $ ":" @ string(int(VSize(Location - V.Location) * 0.01875)) $ Class'HUD_Assault'.Default.MetersString;
            Class'UT2k4Assault.HUD_Assault'.static.Draw_2DCollisionBox(C,V,ScreenPos,VehicleInfoString,1.5,True);

            if(V == CurrentTarget){
                DrawCrosshairAlignment( C, ScreenPos );
            }
          }
        }

    }
  }

  /*
  foreach DynamicActors(Class'xPawn',P)
  {
    if ( (P == self) || (P.Health < 1) || P.bDeleteMe || (P.GetTeamNum() != Team) || (P.bCanTeleport == False) )
    {
      continue;
    } else {
      if (  !Class'HUD_Assault'.static.IsTargetInFrontOfPlayer(C,P,ScreenPos,Location,Rotation) )
      {
        continue;
      } else {
        if (  !FastTrace(P.Location,Location) )
        {
          continue;
        } else {
          C.SetDrawColor(0,255,100,192);
          C.Font = Class'HudBase'.static.GetConsoleFont(C);
          FriendInfoString = "Friend" @ string(int(VSize(Location - P.Location) * 0.01875)) $ Class'HUD_Assault'.Default.MetersString;
          Class'HUD_Assault'.static.Draw_2DCollisionBox(C,P,ScreenPos,FriendInfoString,1.5,True);
        }
      }
    }
  }
  */
  //SpecialDrawCrosshair(C);
  //DrawWeaponInfo(C,PC.myHUD);


	H = HudCDeathmatch(PC.MyHud);
  	HudMissileCount.Tints[0] = H.HudColorRed;
	HudMissileCount.Tints[1] = H.HudColorBlue;

	H.DrawSpriteWidget( C, HudMissileCount );
	H.DrawSpriteWidget( C, HudMissileIcon );
	HudMissileDigits.Value = Apache_Weapon(Weapons[0]).LoadedShotCount;
	H.DrawNumericWidget(C, HudMissileDigits, DigitsBig);

}

/* Visual feedback that weapon will hit where crosshair is aiming at */
simulated function DrawCrosshairAlignment( Canvas C, Vector ScreenPos )
{
	local float		RatioX, RatioY;

	RatioX = C.SizeX / 640.0;
	RatioY = C.SizeY / 480.0;

	C.DrawColor = C.MakeColor(0,255,0,192);
	C.Style		= ERenderStyle.STY_Alpha;
	C.SetPos( ScreenPos.X - 16*RatioX, ScreenPos.Y - 16*RatioY );
	C.DrawTile(CrosshairHitFeedbackTex, 32*RatioX, 32*RatioY, 0.0, 0.0, CrosshairHitFeedbackTex.MaterialUSize(), CrosshairHitFeedbackTex.MaterialVSize() );
}

//Notify vehicle that an enemy has locked on to it
event NotifyEnemyLockedOn()
{
	super.NotifyEnemyLockedOn();

	if ( PlayerController(Controller) != None && LockedOnSound != None )
		PlayerController(Controller).ClientPlaySound( LockedOnSound );
}


//
// Targeting
//

simulated function bool IsTargetRelevant( Vehicle Target )
{
	if ( Target == None ){
//        log("Target is None");
        return false;
	}

	if ( Target.Team == Team){
//        log("Target is on same team");
		return false;
	}

    if(Target.Health < 1 || Target.bDeleteMe || !Target.IndependentVehicle()){
//        log("Target is destroyed");
		return false;
    }

     if(Target.bCanFly){
//        log("Target is out of range ["$MaxTargetingRange$"]:["$String(VSize(Location - Target.Location))$"]");
		return false;
    }

    if(Target.IsVehicleEmpty()==true){
//    if(Target.bTeamLocked == true){
//        log("Target is out of range ["$MaxTargetingRange$"]:["$String(VSize(Location - Target.Location))$"]");
		return false;
    }

    if( VSize(Location - Target.Location) > MaxTargetingRange ){
//        log("Target is out of range ["$MaxTargetingRange$"]:["$String(VSize(Location - Target.Location))$"]");
		return false;
    }

	// Target is located behind spacefighter
	if ( (Target.Location - Location) Dot vector(Rotation) < 0 ){
//        log("Target is behind");
        return false;
     }

     return true;
}

simulated function PrevWeapon()
{
	GetPreviousTarget();
}

simulated function NextWeapon()
{
	GetNextTarget();
}

function GetTarget(){
   if(CurrentTarget != none) return;

   GetBestTarget();
}

function GetNextTarget()
{

	local Vehicle		V, NextTarget;
    local bool isCurrentTargetFound, isNextTargetFound, isFirstTargetFound;

    if(CurrentTarget != none){
        isCurrentTargetFound = false;
    }else{
        isCurrentTargetFound = true;
    }

    isNextTargetFound = false;
    isFirstTargetFound = false;
    foreach DynamicActors(Class'Vehicle',V)
    {

        if(!isFirstTargetFound){
            if(IsTargetRelevant( V )){
                isFirstTargetFound = true;
                NextTarget = V;
            }
        }


        if(!isNextTargetFound){
            if(isCurrentTargetFound){
                if(IsTargetRelevant( V )){
                    isNextTargetFound = true;
                    NextTarget = V;
                }
            }

            if(V == CurrentTarget){
                isCurrentTargetFound = true;
            }
        }
    }
    if(NextTarget==none){
        return;
    }
    ServerSetTarget( NextTarget );
}

function GetPreviousTarget()
{
	local Vehicle		V, NextTarget;
    local bool isCurrentTargetFound;

    foreach DynamicActors(Class'Vehicle',V)
    {
        if(!isCurrentTargetFound){
            if(IsTargetRelevant( V )){
                NextTarget = V;
            }
            if(V == CurrentTarget){
                isCurrentTargetFound = true;
            }
        }

        if(NextTarget == none){
            if(IsTargetRelevant( V )){
                NextTarget = V;
            }
        }
    }

    ServerSetTarget( NextTarget );
}

/* Acquired a new Target */
function ServerSetTarget(Vehicle NewTarget)
{
	if ( PlayerController(Controller) != None )
		PlayerController(Controller).ClientPlaySound( TargetAcquiredSound );

	CurrentTarget = NewTarget;
	bAutoTarget = false;
}

/* Lock closest visible enemy */
function GetBestTarget()
{
	local float CurAim, BestAim;
    local float			BestDist, Dist;
	local Vehicle		V, BestV;
	local rotator WeaponRotation;
	local Apache_Weapon APweapon;

	if ( Role != ROLE_Authority )
		return;

	// Only check target once per second to save CPU
	if ( LastAutoTargetTime + 1 > Level.TimeSeconds )
		return;

	LastAutoTargetTime = Level.TimeSeconds;
    BestDist = MaxTargetingRange;

    APweapon = Apache_Weapon(Weapons[0]);
    WeaponRotation = APweapon.WeaponFireRotation;

  foreach DynamicActors(Class'Vehicle',V)
  {
      if ( IsTargetRelevant(V) )
      {
            /*
			CurAim = Normalize(V.Location - WeaponRotation) dot vector(WeaponRotation);
			if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location))
			{
				BestV = V;
				BestAim = CurAim;
			}
            */
           // CurAim = rotator(V.Location) - WeaponRotation;



			Dist = VSize(Location - V.Location);

			if ( (BestV == None || Dist < BestDist) && LineOfSightTo( V ) ){
				BestV		= V;
				BestDist	= Dist;
			}


      }
  }

	if ( BestV != None )
		ServerSetTarget( BestV );
}


/*
static function StaticPrecache (LevelInfo L)
{
  Super.StaticPrecache(L);
  L.AddPrecacheStaticMesh(StaticMesh'Atakapa_exploded_wing');
  L.AddPrecacheStaticMesh(StaticMesh'Atakapa_exploded_tail');
  L.AddPrecacheStaticMesh(StaticMesh'Atakapa_exploded_rotor');
  L.AddPrecacheStaticMesh(StaticMesh'Veh_Debris2');
  L.AddPrecacheStaticMesh(StaticMesh'Veh_Debris1');
  L.AddPrecacheStaticMesh(StaticMesh'RocketProj');
  L.AddPrecacheMaterial(Texture'SparkHead');
  L.AddPrecacheMaterial(Texture'exp2_frames');
  L.AddPrecacheMaterial(Texture'exp1_frames');
  L.AddPrecacheMaterial(Texture'we1_frames');
  L.AddPrecacheMaterial(Texture'SmokePanels2');
  L.AddPrecacheMaterial(Texture'NapalmSpot');
  L.AddPrecacheMaterial(Texture'SprayFire1');
  L.AddPrecacheMaterial(Texture'TrailBlura');
  L.AddPrecacheMaterial(Texture'GRADIENT_Fade');
  L.AddPrecacheMaterial(Texture'SmokeFragment');
}

simulated function UpdatePrecacheStaticMeshes ()
{
//  Level.AddPrecacheStaticMesh(StaticMesh'Atakapa_exploded_wing');
//  Level.AddPrecacheStaticMesh(StaticMesh'Atakapa_exploded_tail');
//  Level.AddPrecacheStaticMesh(StaticMesh'Atakapa_exploded_rotor');
//  Level.AddPrecacheStaticMesh(StaticMesh'Veh_Debris2');
//  Level.AddPrecacheStaticMesh(StaticMesh'Veh_Debris1');
//  Level.AddPrecacheStaticMesh(StaticMesh'RocketProj');
  Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials ()
{
  Level.AddPrecacheMaterial(Texture'SparkHead');
  Level.AddPrecacheMaterial(Texture'exp2_frames');
  Level.AddPrecacheMaterial(Texture'exp1_frames');
  Level.AddPrecacheMaterial(Texture'we1_frames');
  Level.AddPrecacheMaterial(Texture'SmokePanels2');
  Level.AddPrecacheMaterial(Texture'NapalmSpot');
  Level.AddPrecacheMaterial(Texture'SprayFire1');
  Level.AddPrecacheMaterial(Texture'TrailBlura');
  Level.AddPrecacheMaterial(Texture'GRADIENT_Fade');
  Level.AddPrecacheMaterial(Texture'SmokeFragment');
  Super.UpdatePrecacheMaterials();
}
*/

defaultproperties
{
     MaxPitchSpeed=2000.000000
     TrailEffectClass=Class'W_Apache.Emitter_ApacheExhaust'
     DNSparkEffectClass=Class'W_Apache.Emitter_ApacheSparks'
     ControlLossFactor=0.500000
     BladeBreakSound=Sound'ONSVehicleSounds-S.RV.RVBladeBreakOff'
     TailBone="Bone_tail"
     MaxTargetingRange=20000.000000
     CrosshairTexture=TexRotator'AS_FX_TX.Icons.OBJ_Destroy_TR'
     DefaultCrosshair=FinalBlend'InterfaceContent.HUD.fbBombFocus'
     CrosshairHitFeedbackTex=Texture'ONSInterface-TX.tankBarrelAligned'
     HudMissileCount=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=110,X2=166,Y2=163),TextureScale=0.530000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     HudMissileIcon=(WidgetTexture=Texture'CicadaTex.HUD.RocketIcon',RenderStyle=STY_Alpha,TextureCoords=(X2=32,Y2=64),TextureScale=0.530000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     HudMissileDigits=(RenderStyle=STY_Alpha,TextureScale=0.490000,DrawPivot=DP_MiddleLeft,PosX=0.861000,PosY=1.000000,OffsetX=20,OffsetY=-29,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     DigitsBig=(DigitTexture=Texture'HUDContent.Generic.HUD',TextureCoords[0]=(X2=38,Y2=38),TextureCoords[1]=(X1=39,X2=77,Y2=38),TextureCoords[2]=(X1=78,X2=116,Y2=38),TextureCoords[3]=(X1=117,X2=155,Y2=38),TextureCoords[4]=(X1=156,X2=194,Y2=38),TextureCoords[5]=(X1=195,X2=233,Y2=38),TextureCoords[6]=(X1=234,X2=272,Y2=38),TextureCoords[7]=(X1=273,X2=311,Y2=38),TextureCoords[8]=(X1=312,X2=350,Y2=38),TextureCoords[9]=(X1=351,X2=389,Y2=38),TextureCoords[10]=(X1=390,X2=428,Y2=38))
     UprightStiffness=650.000000
     UprightDamping=400.000000
     MaxThrustForce=120.000000
     LongDamping=0.050000
     MaxStrafeForce=108.000000
     LatDamping=0.050000
     MaxRiseForce=160.000000
     UpDamping=0.030000
     TurnTorqueFactor=600.000000
     TurnTorqueMax=200.000000
     TurnDamping=50.000000
     MaxYawRate=1.500000
     PitchTorqueFactor=500.000000
     PitchTorqueMax=70.000000
     PitchDamping=20.000000
     RollTorqueTurnFactor=450.000000
     RollTorqueStrafeFactor=50.000000
     RollTorqueMax=50.000000
     RollDamping=30.000000
     StopThreshold=100.000000
     MaxRandForce=3.000000
     RandForceInterval=0.750000
     DriverWeapons(0)=(WeaponClass=Class'W_Apache.Apache_Weapon',WeaponBone="Bone_50cal")
     StartUpSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftStartUp'
     ShutDownSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftShutDown'
     StartUpForce="AttackCraftStartUp"
     ShutDownForce="AttackCraftShutDown"
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DamagedEffectOffset=(X=-20.000000,Y=10.000000,Z=15.000000)
     ImpactDamageMult=0.000000
     VehicleMass=9.000000
     bTurnInPlace=True
     bShowDamageOverlay=True
     bDesiredBehindView=False
     bDriverHoldsFlag=False
     bCanCarryFlag=False
     EntryPosition=(X=-40.000000)
     EntryRadius=300.000000
     TPCamDistance=900.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=300.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in an Apache"
     VehicleNameString="Apache"
     RanOverDamageType=Class'Onslaught.DamTypeAttackCraftRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypeAttackCraftPancake'
     FlagBone="Bone_50cal"
     FlagOffset=(Z=80.000000)
     FlagRotation=(Yaw=32768)
     GroundSpeed=2000.000000
     HealthMax=400.000000
     Health=400
     Mesh=SkeletalMesh'DN_AtakapaAnim.DNAtakapa'
     DrawScale=0.600000
     CollisionRadius=130.000000
     CollisionHeight=60.000000
     KParams=KarmaParamsRBFull'Onslaught.ONSAttackCraft.KParams0'

}
