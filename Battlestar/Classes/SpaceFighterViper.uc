//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SpaceFighterViper extends SpaceFighterBase;

/*
simulated function SetTrailFX()
{
    // Trail FX
    if ( TrailEffects.Length > 0 && Health>0 && Team != 255  )
    {

        TrailEmitter = Spawn(class'FX_SpaceFighter_Trail_Red', Self,, Location - Vector(Rotation)*TrailOffset, Rotation);

        if ( TrailEmitter != None )
        {
            if ( Team == 1 )    // Blue version
                FX_SpaceFighter_Trail_Red(TrailEmitter).SetBlueColor();

            TrailEmitter.SetBase( self );
        }

    }

}
*/
simulated function AdjustFX()
{
    local float         NewSpeed, VehicleSpeed, SpeedPct;
    local int           i, averageOver;

    // Check that Trail is here
    SetTrailFX();

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

    if ( NextSpeedFilterSlot == SpeedFilterFrames )
    {
        NextSpeedFilterSlot = 0;
        bSpeedFilterWarmup  = false;
    }

    SmoothedSpeedRatio = VehicleSpeed / AirSpeed;
    SpeedPct = VehicleSpeed - EngineMinVelocity*AirSpeed/EngineMaxVelocity;
    SpeedPct = FClamp( SpeedPct / (AirSpeed*( (EngineMaxVelocity-EngineMinVelocity)/EngineMaxVelocity )), 0.f, 1.f );

    // Adjust Engine FX depending on velocity
    //if ( TrailEmitter != None )
//    AdjustEngineFX( SpeedPct );
//    UpdateEngineSound( SpeedPct );
    AdjustEngineFX( VehicleSpeed/EngineMaxVelocity );
    UpdateEngineSound( VehicleSpeed/EngineMaxVelocity );

    // Adjust FOV depending on speed
    if ( PlayerController(Controller) != None && IsLocallyControlled() )
        PlayerController(Controller).SetFOV( PlayerController(Controller).DefaultFOV + SpeedPct*SpeedPct*15  );
}

simulated function UpdateEngineSound( float SpeedPct )
{
    // Adjust Engine volume
    SoundVolume = 160 +  32 * SpeedPct;
    SoundPitch  =  64 +  16 * SpeedPct;
}

simulated function AdjustEngineFX( float SpeedPct )
{
/*
    local SpriteEmitter E1, E2;

    E1 = SpriteEmitter(TrailEmitter.Emitters[1]);
    E2 = SpriteEmitter(TrailEmitter.Emitters[2]);

    // Thruster
    E1.SizeScale[1].RelativeSize = 2.00 + 1.0*SpeedPct;
    E1.SizeScale[2].RelativeSize = 2.00 + 1.5*SpeedPct;
    E1.SizeScale[3].RelativeSize = 2.00 + 1.0*SpeedPct;
    E1.Opacity = 1 - SpeedPct * 0.5;

    E2.Opacity = 0.5 + SpeedPct * 0.25;
    E2.StartSizeRange.X.Min = 40 + 10 * SpeedPct;
    E2.StartSizeRange.X.Max = 50 + 25 * SpeedPct;
*/

    local vector RotX, RotY, RotZ;
    local int i;

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
    {
        GetAxes(Rotation,RotX,RotY,RotZ);

        if (TrailEffects.Length == 0)
        {
            TrailEffects.Length = TrailEffectPositions.Length;

            for(i=0;i<TrailEffects.Length;i++)
                if (TrailEffects[i] == None)
                {
                    TrailEffects[i] = spawn(TrailEffectClass, self,, Location + (TrailEffectPositions[i] >> Rotation) );
                    TrailEffects[i].SetBase(self);
                    TrailEffects[i].SetRelativeRotation( rot(0,32768,0) );
                }
        }

    }
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
        {
            for(i=0;i<TrailEffects.Length;i++)
               TrailEffects[i].Destroy();

            TrailEffects.Length = 0;

        }
    }
}

simulated function ClientKDriverEnter(PlayerController PC)
{
    super.ClientKDriverEnter( PC );

    // Don't start at full speed
    Velocity = EngineMinVelocity * Vector(Rotation);
    Acceleration = Velocity;
}

function float ImpactDamageModifier()
{
    return ImpactDamageMult;
}

DefaultProperties
{
    mesh=SkeletalMesh'VI.VI'
    Skins[0]=texture'BSGVehicles.BSGVehicles.Viper'

    //DriverWeapons(0)=(WeaponClass=class'Onslaught.ONSAttackCraftGun',WeaponBone=PlasmaGunAttachment);

    MinFlySpeed=0.0
    EngineMinVelocity=0.0

    ImpactDamageMult=0.3;

    bCollideActors=True
    bBlockActors=True

//    TrailEffectPositions(0)=(X=-148,Y=-26,Z=51);
//    TrailEffectPositions(1)=(X=-148,Y=26,Z=51);
//    TrailEffectPositions(2)=(X=-140,Y=0,Z=40);
    TrailEffectPositions(0)=(X=-135,Y=-35,Z=5);
    TrailEffectPositions(1)=(X=-135,Y=35,Z=5);
    TrailEffectPositions(2)=(X=-135,Y=0,Z=33);
//    TrailEffectClass=class'Battlestar.SpaceFighterTurboExhaust'
    TrailEffectClass=class'ViperAttackCraftExhaust'

    VehiclePositionString="in a Colonial Viper Mk II"
    VehicleNameString="Colonial Viper Mk II"
}