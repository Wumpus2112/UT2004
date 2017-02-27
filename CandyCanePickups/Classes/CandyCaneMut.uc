class CandyCaneMut extends Mutator;

var string AdrenalinePickupClassName, MiniHealthPackClassName;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{

    bSuperRelevant = 0;
    if ( (AdrenalinePickup(Other) != None) && (string(Other.class) != AdrenalinePickupClassName) ){
        log("AdrenalinePickup:"@string(Other.class));
        ReplaceWith( Other, AdrenalinePickupClassName);
        return false;
    }
    if ( (MiniHealthPack(Other) != None) && (string(Other.class) != MiniHealthPackClassName) ){
        log("MiniHealthPack:"@string(Other.class));
        ReplaceWith( Other, MiniHealthPackClassName);
        return false;
    }

    return true;
}

defaultproperties
{
    AdrenalinePickupClassName="CandyCanePickups.RedCandyCane"
    MiniHealthPackClassName="CandyCanePickups.BlueCandyCane"

    bAlwaysRelevant=true
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=true

    IconMaterialName="MutatorArt.nosym"
    GroupName="Health Pickups"
    FriendlyName="Candy Cane Pickups"
    Description="Replace Mini Health and Adrenaline with Candy Canes"
}
