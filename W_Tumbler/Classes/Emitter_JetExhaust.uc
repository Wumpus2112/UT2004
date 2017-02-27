//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Emitter_JetExhaust extends Emitter;


simulated function SetThrust (float Amount)
{
  Emitters[0].StartSizeRange.X.Min = -0.1 - Amount * 0.31;
  Emitters[0].StartSizeRange.X.Max = -0.2 - Amount * 0.81;
  Emitters[1].StartVelocityRange.X.Min = 150.0 + Amount * 250;
  Emitters[1].StartVelocityRange.X.Max = Emitters[1].StartVelocityRange.X.Min;
  Emitters[1].ParticlesPerSecond = 30.0 + Amount * 70;
  Emitters[1].InitialParticlesPerSecond = 30.0 + Amount * 70;
}

simulated function SetThrustEnabled (bool bDoThrust)
{
  if ( bDoThrust )
  {
    Emitters[0].Disabled = False;
    Emitters[1].Disabled = False;
  } else {
    Emitters[0].Disabled = True;
    Emitters[1].Disabled = False;
  }
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter18
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(B=176,G=223,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.150000,Color=(B=32,G=166,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.300000,Color=(B=108,G=146,R=183,A=200))
         ColorScale(3)=(RelativeTime=0.750000,Color=(B=80,G=80,R=80,A=128))
         ColorScale(4)=(RelativeTime=1.000000)
         MaxParticles=30
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=20.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=7.000000)
         StartSizeRange=(X=(Min=20.000000,Max=40.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'ExplosionTex.Framed.exp2_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'W_Tumbler.Emitter_JetExhaust.SpriteEmitter18'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter19
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=200,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=74,G=169,R=255,A=160))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=108,G=146,R=183,A=64))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=80,G=80,R=80))
         MaxParticles=60
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=12.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=15.000000,Max=30.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.Smokepuff'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.400000,Max=0.400000)
     End Object
     Emitters(1)=SpriteEmitter'W_Tumbler.Emitter_JetExhaust.SpriteEmitter19'

     AutoDestroy=True
     CullDistance=12000.000000
     bNoDelete=False
     DrawScale=0.700000
     AmbientGlow=140
     bHardAttach=True
}
