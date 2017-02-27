//=============================================================================
// ONSAttackCraftExhaust.
//=============================================================================
// Placement offsets are:
// X=147.695313,Y=-25.922363,Z=51.000000
// and
// X=147.612320,Y=27.779526,Z=51.000000
//=============================================================================

class HoverboardTrail extends Emitter
    placeable;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"

simulated function SetThrust(float Amount)
{
    Emitters[0].StartSizeRange.X.Min = -0.1 - (Amount * 0.3);
    Emitters[0].StartSizeRange.X.Max = -0.2 - (Amount * 0.8);

    Emitters[1].StartVelocityRange.X.Min = 150 + (Amount * 250);
    Emitters[1].StartVelocityRange.X.Max = Emitters[1].StartVelocityRange.X.Min;

    Emitters[1].ParticlesPerSecond = 30 + (Amount * 70);
    Emitters[1].InitialParticlesPerSecond = 30 + (Amount * 70);
}

simulated function SetThrustEnabled(bool bDoThrust)
{
    if(bDoThrust)
    {
        Emitters[0].Disabled = false;
        Emitters[1].Disabled = false;
    }
    else
    {
        Emitters[0].Disabled = true;
        Emitters[1].Disabled = true;
    }
}

DefaultProperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        UseVelocityScale=True
        Acceleration=(Z=175.000000)
        ColorScale(0)=(Color=(B=192,G=192,R=192))
        ColorScale(1)=(RelativeTime=0.100000,Color=(B=160,G=160,R=160,A=255))
        ColorScale(2)=(RelativeTime=0.800000,Color=(B=128,G=128,R=128,A=192))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
        MaxParticles=50
        StartLocationRange=(Z=(Max=20.000000))
        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
        StartSizeRange=(X=(Min=50.000000,Max=50.000000))
        ParticlesPerSecond=25.000000
        InitialParticlesPerSecond=25.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=AW-2004Particles.Weapons.DustSmoke
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=2.500000,Max=1.500000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=200.000000,Max=200.000000))
        VelocityScale(0)=(RelativeVelocity=(Z=0.500000))
        VelocityScale(1)=(RelativeTime=0.500000,RelativeVelocity=(X=0.200000,Y=0.200000,Z=0.200000))
        VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=1.000000,Y=1.000000,Z=0.200000))
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseColorScale=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=50.000000)
        ColorScale(1)=(RelativeTime=0.500000,Color=(B=34,G=135,R=210,A=255))
        ColorScale(2)=(RelativeTime=0.600000,Color=(B=255,G=255,R=255,A=64))
        ColorScale(3)=(RelativeTime=1.000000)
        Opacity=0.500000
        CoordinateSystem=PTCS_Relative
        MaxParticles=4
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
        StartLocationShape=PTLS_All
        SpinsPerSecondRange=(X=(Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.200000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
        StartSizeRange=(X=(Min=10.000000,Max=20.000000))
        ParticlesPerSecond=8.000000
        InitialParticlesPerSecond=8.000000
        Texture=Texture'AW-2004Particles.Fire.NapalmSpot'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(Z=(Min=4.000000,Max=4.000000))
        RespawnDeadParticles=False
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'

    AutoDestroy=True

    CullDistance=12000.00

    bNoDelete=False

    AmbientGlow=140

    bHardAttach=True
}
