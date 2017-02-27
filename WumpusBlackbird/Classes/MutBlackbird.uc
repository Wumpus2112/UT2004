//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutBlackbird extends Mutator;

var string ScorpionFactory;

var class<ONSVehicle> ScorpionReplacement;

function PostBeginPlay()
{
    local ONSVehicleFactory Factory;
    local String FactoryName;

    foreach AllActors( class 'ONSVehicleFactory', Factory )
    {
        FactoryName = Left(String(Factory.name),Len(ScorpionFactory));
            if ( FactoryName == ScorpionFactory){
                Factory.VehicleClass = ScorpionReplacement;
            }else{
                log("Not replaced:"$String(Factory.name));
            }
    }

    Super.PostBeginPlay();
}

DefaultProperties
{
    bAddToServerPackages=True
    ScorpionFactory="ONSAttackCraftFactory"
    ScorpionReplacement=class'BSGBlackbird'

    GroupName="ONSAttackCraft"
    FriendlyName="Wumpus Blackbird All"
    Description="Replaces ONSChopperCraft with Blackbird"
}
