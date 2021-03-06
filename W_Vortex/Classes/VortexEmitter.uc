/*******************************************************************************
 * VortexEmitter generated by Eliot.UELib using UE Explorer.
 * Eliot.UELib ? 2009-2013 Eliot van Uytfanghe. All rights reserved.
 * http://eliotvu.com
 *
 * All rights belong to their respective owners.
 *******************************************************************************/
class VortexEmitter extends Emitter;

simulated function PostBeginPlay()
{
    super(Actor).PostBeginPlay();
    SetTimer(11.0, false);
    //return;
}

simulated function Timer()
{
    Kill();
    //return;
}

simulated function Tick(float DeltaTime)
{
    local float Alpha;

    Alpha = 0.10 * (default.LifeSpan - LifeSpan);
    SpriteEmitter(Emitters[0]).FadeOutStartTime = Lerp(Alpha, 0.40, 1.0);
    SpriteEmitter(Emitters[0]).StartVelocityRadialRange.Min = Lerp(Alpha, -10.0, -25.0);
    SpriteEmitter(Emitters[0]).StartVelocityRadialRange.Max = Lerp(Alpha, -10.0, -25.0);
    SpriteEmitter(Emitters[0]).SphereRadiusRange.Min = Lerp(Alpha, 150.0, 500.0);
    SpriteEmitter(Emitters[0]).SphereRadiusRange.Max = Lerp(Alpha, 150.0, 500.0);
    SpriteEmitter(Emitters[0]).LifetimeRange.Min = Lerp(Alpha, 0.250, 1.50);
    SpriteEmitter(Emitters[0]).LifetimeRange.Max = Lerp(Alpha, 0.250, 1.50);
    //return;
}

defaultproperties
{

    bNoDelete=false
    Physics=PHYS_Trailer
    LifeSpan=13.60
    /*

    Begin Object Class=SpriteEmitter Name=SpriteEmitter80
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(X=500.000000)
         ColorScale(0)=(Color=(B=255,G=64,R=128))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=64,R=128))
         ColorScale(2)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Y=(Max=1.500000),Z=(Min=0.670000))
         Opacity=0.670000
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartLocationRange=(X=(Max=32.000000))
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Max=32.000000)
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=10.000000,Max=150.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'EpicParticles.Flares.HotSpot'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.600000,Max=0.600000)
         StartVelocityRange=(X=(Max=750.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=-400.000000,Max=400.000000))
     End Object
    Emitters(0)=SpriteEmitter'W_Vortex.VortexEmitter.SpriteEmitter80'
    */

    Begin Object Class=SpriteEmitter Name=SpriteEmitter80
        UseColorScale=true
        FadeOut=true
        FadeIn=true
        UniformSize=true
        UseVelocityScale=true
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
        FadeOutStartTime=1.0
        FadeInEndTime=0.10
        MaxParticles=150
        StartLocationShape=1
        SphereRadiusRange=(Min=512.0,Max=512.0)
        RevolutionsPerSecondRange=(X=(Min=0.0,Max=0.0),Y=(Min=0.0,Max=0.0),Z=(Min=0.20,Max=0.50))
         RevolutionScale(0)=(RelativeRevolution=(Z=2.000000))
         RevolutionScale(1)=(RelativeTime=0.600000)
         RevolutionScale(2)=(RelativeTime=1.000000,RelativeRevolution=(Z=2.000000))
        SpinsPerSecondRange=(X=(Min=0.0,Max=4.0),Y=(Min=0.0,Max=0.0),Z=(Min=0.0,Max=0.0))
        StartSizeRange=(X=(Min=4.0,Max=4.0),Y=(Min=4.0,Max=4.0),Z=(Min=8.0,Max=8.0))
        Texture=Texture'EpicParticles.Flares.HotSpot'
        LifetimeRange=(Min=1.50,Max=1.50)
        StartVelocityRadialRange=(Min=-20.0,Max=-20.0)
        VelocityLossRange=(X=(Min=1.0,Max=1.0),Y=(Min=1.0,Max=1.0),Z=(Min=1.0,Max=1.0))
        GetVelocityDirectionFrom=3

        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.200000,RelativeVelocity=(X=0.350000,Y=0.350000,Z=0.350000))
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
        VelocityScale(3)=(RelativeTime=1.000000)
     End Object
    Emitters(0)=SpriteEmitter'W_Vortex.VortexEmitter.SpriteEmitter80'


    /*
    begin object name=VortexEmitter2 class=SpriteEmitter
        UseColorScale=true
        FadeOut=true
        FadeIn=true
        UniformSize=true
        UseVelocityScale=true
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
        FadeOutStartTime=1.0
        FadeInEndTime=0.10
        MaxParticles=150
        StartLocationShape=1
        SphereRadiusRange=(Min=512.0,Max=512.0)
        RevolutionsPerSecondRange=(X=(Min=0.0,Max=0.0),Y=(Min=0.0,Max=0.0),Z=(Min=0.20,Max=0.50))
         RevolutionScale(0)=(RelativeRevolution=(Z=2.000000))
         RevolutionScale(1)=(RelativeTime=0.600000)
         RevolutionScale(2)=(RelativeTime=1.000000,RelativeRevolution=(Z=2.000000))
        SpinsPerSecondRange=(X=(Min=0.0,Max=4.0),Y=(Min=0.0,Max=0.0),Z=(Min=0.0,Max=0.0))
        StartSizeRange=(X=(Min=4.0,Max=4.0),Y=(Min=4.0,Max=4.0),Z=(Min=8.0,Max=8.0))
        Texture=Texture'EpicParticles.Flares.HotSpot'
        LifetimeRange=(Min=1.50,Max=1.50)
        StartVelocityRadialRange=(Min=-20.0,Max=-20.0)
        VelocityLossRange=(X=(Min=1.0,Max=1.0),Y=(Min=1.0,Max=1.0),Z=(Min=1.0,Max=1.0))
        GetVelocityDirectionFrom=3

        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.200000,RelativeVelocity=(X=0.350000,Y=0.350000,Z=0.350000))
        VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
        VelocityScale(3)=(RelativeTime=1.000000)
    object end
    Emitters(0)=SpriteEmitter'W_Vortex.VortexEmitter.VortexEmitter2'
    */

}
