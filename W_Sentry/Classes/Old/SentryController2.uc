//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SentryController2 extends ASSentinelController;


var     bool        bLeadTarget;        // lead target with projectile attack
var float           Accuracy;           // -1 to 1 (0 is default, higher is more accurate)
const AngleConvert = 0.0000958738;  // 2*PI/65536

function float AdjustAimError(float aimerror, float TargetDist, bool bDefendMelee, bool bInstantProj, bool bLeadTargetNow )
{
    local float aimdist, desireddist, NewAngle;
    local vector VelDir, AccelDir;

    log("Sentry Controller - AdjustAimError");

    // figure out the relative motion of the target across the bots view, and adjust aim error
    // based on magnitude of relative motion
    aimerror = aimerror * FMin(5,(12 - 11 *
        (Normal(Target.Location - Pawn.Location) Dot Normal((Target.Location + 1.2 * Target.Velocity) - (Pawn.Location + Pawn.Velocity)))));

    if ( (Pawn(Target) != None) && Pawn(Target).bStationary )
    {
        aimerror *= 0.15;
        return (Rand(2 * aimerror) - aimerror);
    }

    // if enemy is charging straight at bot with a melee weapon, improve aim
    if ( bDefendMelee )
        aimerror *= 0.5;

    if ( Target.Velocity == vect(0,0,0) )
        aimerror *= 0.2 + 0.1 * (7 - FMin(7,Skill));
    else if ( Skill + Accuracy > 5 )
    {
        VelDir = Target.Velocity;
        VelDir.Z = 0;
        AccelDir = Target.Acceleration;
        AccelDir.Z = 0;
        if ( (AccelDir == vect(0,0,0)) || (Normal(VelDir) Dot Normal(AccelDir) > 0.95) )
            aimerror *= 0.8;
    }

    // aiming improves over time if stopped
        aimerror *= 0.3;


    // adjust aim error based on skill
//    if ( !bDefendMelee )
//        aimerror *= (3.3 - 0.38 * 8 + 0.5 * FRand()));


    aimerror = 2 * aimerror * FRand() - aimerror;
    if ( abs(aimerror) > 700 )
    {
        if ( bInstantProj )
            DesiredDist = 100;
        else
            DesiredDist = 320;
        DesiredDist += Target.CollisionRadius;
        aimdist = tan(AngleConvert * aimerror) * targetdist;
        if ( abs(aimdist) > DesiredDist )
        {
            NewAngle = ATan(DesiredDist,TargetDist)/AngleConvert;
            if ( aimerror > 0 )
                aimerror = NewAngle;
            else
                aimerror = -1 * NewAngle;
        }
    }
    //return aimerror;
    return 0;
}

/*
AdjustAim()
Returns a rotation which is the direction the bot should aim - after introducing the appropriate aiming error
*/

function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
    local rotator FireRotation, TargetLook;
    local float FireDist, TargetDist, ProjSpeed,TravelTime;
    local actor HitActor;
    local vector FireSpot, FireDir, TargetVel, HitLocation, HitNormal;
    local bool bDefendMelee, bClean, bLeadTargetNow;

    log("Sentry Controller - AdjustAim");

    if ( FiredAmmunition.ProjectileClass != None )
        projspeed = FiredAmmunition.ProjectileClass.default.speed;

    log("projspeed:"@projspeed);

    // make sure bot has a valid target
    if ( Target == None )
    {
        Target = Enemy;
        if ( Target == None )
            return Rotation;
    }

    if ( Pawn(Target) != None )
        Target = Pawn(Target).GetAimTarget();

    FireSpot = Target.Location;
    TargetDist = VSize(Target.Location - Pawn.Location);

    // perfect aim at stationary objects
    if ( Pawn(Target) == None )
    {
        if ( !FiredAmmunition.bTossed )
            return rotator(Target.Location - projstart);
        else
        {
            FireDir = AdjustToss(projspeed,ProjStart,Target.Location,true);
            SetRotation(Rotator(FireDir));
            return Rotation;
        }
    }

    bLeadTargetNow = FiredAmmunition.bLeadTarget && bLeadTarget;

    aimerror = AdjustAimError(aimerror,TargetDist,bDefendMelee,FiredAmmunition.bInstantHit, bLeadTargetNow);

    // lead target with non instant hit projectiles
    if ( bLeadTargetNow )
    {
        TargetVel = Target.Velocity;
        TravelTime = TargetDist/projSpeed;
        // hack guess at projecting falling velocity of target
        if ( Target.Physics == PHYS_Falling )
        {
            if ( Target.PhysicsVolume.Gravity.Z <= Target.PhysicsVolume.Default.Gravity.Z )
                TargetVel.Z = FMin(TargetVel.Z + FMax(-400, Target.PhysicsVolume.Gravity.Z * FMin(1,TargetDist/projSpeed)),0);
            else
            {
                TargetVel.Z = TargetVel.Z + 0.5 * TravelTime * Target.PhysicsVolume.Gravity.Z;
                FireSpot = Target.Location + TravelTime*TargetVel;
                HitActor = Trace(HitLocation, HitNormal, FireSpot, Target.Location, false);
                bLeadTargetNow = false;
                if ( HitActor != None )
                    FireSpot = HitLocation + vect(0,0,2);
            }
        }

        if ( bLeadTargetNow )
        {
            // more or less lead target (with some random variation)
            FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * TargetVel * TravelTime;
            FireSpot.Z = FMin(Target.Location.Z, FireSpot.Z);
        }
        if ( (Target.Physics != PHYS_Falling) && (FRand() < 0.55) && (VSize(FireSpot - ProjStart) > 1000) )
        {
            // don't always lead far away targets, especially if they are moving sideways with respect to the bot
            TargetLook = Target.Rotation;
            if ( Target.Physics == PHYS_Walking )
                TargetLook.Pitch = 0;
            bClean = ( ((Vector(TargetLook) Dot Normal(Target.Velocity)) >= 0.71) && FastTrace(FireSpot, ProjStart) );
        }
        else // make sure that bot isn't leading into a wall
            bClean = FastTrace(FireSpot, ProjStart);
        if ( !bClean)
        {
            // reduce amount of leading
            if ( FRand() < 0.3 )
                FireSpot = Target.Location;
            else
                FireSpot = 0.5 * (FireSpot + Target.Location);
        }
    }

    bClean = false; //so will fail first check unless shooting at feet
    if ( FiredAmmunition.bTrySplash && (Pawn(Target) != None) && ((Skill >=4) || bDefendMelee)
        && (((Target.Physics == PHYS_Falling) && (Pawn.Location.Z + 80 >= Target.Location.Z))
            || ((Pawn.Location.Z + 19 >= Target.Location.Z) && (bDefendMelee || (skill > 6.5 * FRand() - 0.5)))) )
    {
        HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,1) * (Target.CollisionHeight + 6), FireSpot, false);
        bClean = (HitActor == None);
        if ( !bClean )
        {
            FireSpot = HitLocation + vect(0,0,3);
            bClean = FastTrace(FireSpot, ProjStart);
        }
        else
            bClean = ( (Target.Physics == PHYS_Falling) && FastTrace(FireSpot, ProjStart) );
    }

    if ( !bClean )
    {
        //try middle
        FireSpot.Z = Target.Location.Z;
        bClean = FastTrace(FireSpot, ProjStart);
    }
    if ( FiredAmmunition.bTossed && !bClean && bEnemyInfoValid )
    {
        FireSpot = LastSeenPos;
        HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
        if ( HitActor != None )
        {

            FireSpot += 2 * Target.CollisionHeight * HitNormal;
        }
        bClean = true;
    }

    if( !bClean )
    {
        // try head
        FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
        bClean = FastTrace(FireSpot, ProjStart);
    }
    if ( !bClean && (Target == Enemy) && bEnemyInfoValid )
    {
        FireSpot = LastSeenPos;
        if ( Pawn.Location.Z >= LastSeenPos.Z )
            FireSpot.Z -= 0.4 * Enemy.CollisionHeight;
        HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
        if ( HitActor != None )
        {
            FireSpot = LastSeenPos + 2 * Enemy.CollisionHeight * HitNormal;
            if ( Pawn.Weapon != None && Pawn.Weapon.SplashDamage() && (Skill >= 4) )
            {
                HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
                if ( HitActor != None )
                    FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
            }

        }
    }

    // adjust for toss distance
    if ( FiredAmmunition.bTossed )
        FireDir = AdjustToss(projspeed,ProjStart,FireSpot,true);
    else
    {
        FireDir = FireSpot - ProjStart;
        if ( Pawn(Target) != None )
            FireDir = FireDir + Pawn(Target).GetTargetLocation() - Target.Location;
    }

    FireRotation = Rotator(FireDir);

    FireDir = vector(FireRotation);
    // avoid shooting into wall
    FireDist = FMin(VSize(FireSpot-ProjStart), 400);
    FireSpot = ProjStart + FireDist * FireDir;
    HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
    if ( HitActor != None )
    {
        if ( HitNormal.Z < 0.7 )
        {

            FireDir = vector(FireRotation);
            FireSpot = ProjStart + FireDist * FireDir;
            HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
        }
        if ( HitActor != None )
        {
            FireSpot += HitNormal * 2 * Target.CollisionHeight;
            if ( Skill >= 4 )
            {
                HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
                if ( HitActor != None )
                    FireSpot += Target.CollisionHeight * HitNormal;
            }
            FireDir = Normal(FireSpot - ProjStart);
            FireRotation = rotator(FireDir);
        }
    }
    InstantWarnTarget(Target,FiredAmmunition,vector(FireRotation));
    ShotTarget = Pawn(Target);

    SetRotation(FireRotation);
    return FireRotation;
}


function float GetScanDelay()
{
    return 2;
}

function float GetWaitForTargetTime()
{
    log("Sentry Controller - GetWaitForTargetTime");
    return 2;
}


DefaultProperties
{
        Skill = 10;
        FocusLead = 0;
        Accuracy = 1;
        bLeadTarget=true;


        Sentry
}
