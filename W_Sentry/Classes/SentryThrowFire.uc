//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SentryThrowFire extends BioFire;

//var class<Projectile> RedMineClass;
//var class<Projectile> BlueMineClass;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local class<actor> NewClass;
    local vector SpawnLoc;
    local actor newTurret,newController;
    local string ClassName;
    local Sentry myTurret;
    local SentryController myController;

    if (SentryLayer(Weapon) != None)
    {

            ClassName = "W_Sentry.Sentry";

            NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
            if( NewClass!=None )
            {
                SpawnLoc = findFloor(Start);
//                newTurret = Spawn( NewClass,,,SpawnLoc + 72 * vector(Dir) + vect(0,0,1) * 15 );
                newTurret = Spawn( NewClass,,,SpawnLoc);

                myTurret = Sentry(newTurret);
                myTurret.TeamNumber = Weapon.Instigator.GetTeamNum();

                if(myTurret != none){
                    //myTurret.Controller.UnPossess();

        			//newController = spawn(myTurret.AutoTurretControllerClass);
        			///myController = SentryController(newController);
		    		//myController.Possess(myTurret);
		    		//myController.Pawn = myTurret;

                    log("myTurret: "@myTurret.Controller.Class);
                    myController = SentryController(myTurret.Controller);
                    myController.TeamNumber = Weapon.Instigator.GetTeamNum();
                }else{
                    log("TURRET CONTROLLER is NONE!!!");
                }
            }else{
                log("error Sentry not created");
            }

    }else{
        log("Sentry class not found:"@Weapon);
    }

    return none;
}

function vector findFloor(Vector Start){
   local vector down, End, HitLocation, HitNormal, StartLocation;
   local Actor Other;

   down = vect(0,0,-1);
   End = Start + 1000.0 * down;

   Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

   if(Other == none){
       StartLocation = Start;
   }else{
       StartLocation = HitLocation;
       StartLocation.Z = StartLocation.Z + 75.0;
   }

   return StartLocation;
}
/*
function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
    local Actor Other;
    local SniperWallHitEffect S;
    local Pawn HeadShotPawn;

    Weapon.GetViewAxes(X, Y, Z);
    if ( Weapon.WeaponCentered() )
        ArcEnd = (Instigator.Location +
			Weapon.EffectOffset.X * X +
			1.5 * Weapon.EffectOffset.Z * Z);
	else
        ArcEnd = (Instigator.Location +
			Instigator.CalcDrawOffset(Weapon) +
			Weapon.EffectOffset.X * X +
			Weapon.Hand * Weapon.EffectOffset.Y * Y +
			Weapon.EffectOffset.Z * Z);

    X = Vector(Dir);
    End = Start + TraceRange * X;
    Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);
    if ( (Level.NetMode != NM_Standalone) || (PlayerController(Instigator.Controller) == None) )
		Weapon.Spawn(class'TracerProjectile',Instigator.Controller,,Start,Dir);
    if ( Other != None && (Other != Instigator) )
    {
        if ( !Other.bWorldGeometry )
        {
            if (Vehicle(Other) != None)
                HeadShotPawn = Vehicle(Other).CheckForHeadShot(HitLocation, X, 1.0);

            if (HeadShotPawn != None)
                HeadShotPawn.TakeDamage(DamageMax * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
 			else if ( (Pawn(Other) != None) && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
                Other.TakeDamage(DamageMax * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
            else
                Other.TakeDamage(DamageMax, Instigator, HitLocation, Momentum*X, DamageType);
        }
        else
				HitLocation = HitLocation + 2.0 * HitNormal;
    }
    else
    {
        HitLocation = End;
        HitNormal = Normal(Start - End);
    }

    if ( (HitNormal != Vect(0,0,0)) && (HitScanBlockingVolume(Other) == None) )
    {
		S = Weapon.Spawn(class'SniperWallHitEffect',,, HitLocation, rotator(-1 * HitNormal));
		if ( S != None )
			S.FireStart = Start;
	}
}
*/

defaultproperties
{
     FireSound=Sound'ONSVehicleSounds-S.SpiderMines.SpiderMineFire01'
     FireRate=1.100000
     AmmoClass=Class'W_Sentry.SentryAmmo'
}
