//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FX_HydraTrail extends ONSDualMissileSmokeTrail;

DefaultProperties
{

    Begin Object Class=TrailEmitter Name=TrailEmitter4
        TrailShadeType=PTTST_PointLife
        TrailLocation=PTTL_FollowEmitter
        MaxPointsPerTrail=150
        DistanceThreshold=10.000000
        UseCrossedSheets=True
        PointLifeTime=0.450000
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(color=(B=255,G=255,R=55))
        MaxParticles=1
        StartSizeRange=(X=(Min=80.000000,Max=80.000000))
        InitialParticlesPerSecond=2000.000000
        Texture=Texture'AW-2k4XP.Cicada.MissileTrail1a'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=999999.000000,Max=999999.000000)
    End Object
    Emitters(0)=TrailEmitter'TrailEmitter4'

}
