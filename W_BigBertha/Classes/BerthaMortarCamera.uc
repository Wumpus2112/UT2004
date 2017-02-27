//=============================================================================
// BerthaMortarCamera.
//=============================================================================
class BerthaMortarCamera extends ONSMortarCamera;

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    if ((Damage > 0) && ((InstigatedBy == None) || (InstigatedBy.Controller == None) || (Instigator == None) || (Instigator.Controller == None) || !InstigatedBy.Controller.SameTeamAs(Instigator.Controller)))
	{
        bShotDown = True;
		ShotDown();
	}
}


// Decompiled with UE Explorer.
defaultproperties
{
    MyDamageType=class'DamTypeArtilleryShellNEW'
}