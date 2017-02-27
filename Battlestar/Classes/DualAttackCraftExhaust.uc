//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DualAttackCraftExhaust extends ONSAttackCraftExhaust;
#exec OBJ LOAD FILE="..\Textures\AW-2004Explosions.utx"
simulated function SetThrust(float Amount)
{
    Emitters[0].StartSizeRange.X.Min = -0.1 - (Amount * 1.3);
    Emitters[0].StartSizeRange.X.Max = -0.2 - (Amount * 1.8);

    Emitters[1].StartVelocityRange.X.Min = 150 + (Amount * 250);
    Emitters[1].StartVelocityRange.X.Max = Emitters[1].StartVelocityRange.X.Min;

    Emitters[1].StartSizeRange.X.Min = (Amount)*10;
    Emitters[1].StartSizeRange.X.Max = (Amount)*40;

    Emitters[1].ParticlesPerSecond = 30 + (Amount * 70);
    Emitters[1].InitialParticlesPerSecond = 30 + (Amount * 70);
}

DefaultProperties
{

}