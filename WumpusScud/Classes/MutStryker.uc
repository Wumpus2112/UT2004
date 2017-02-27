//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutStryker extends Mutator;

var string ScorpionFactory;

var class<ONSVehicle> ScorpionReplacement;

function PostBeginPlay()
{
    local ONSVehicleFactory Factory;
    local String FactoryName;

    foreach AllActors( class 'ONSVehicleFactory', Factory )
    {
        FactoryName = Left(String(Factory.name),19);
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
    ScorpionFactory="ONSArtilleryFactory"
    ScorpionReplacement=class'WumpusScud'

    GroupName="ONSArtillery"
    FriendlyName="Wumpus Stryker All"
    Description="Replaces Artillery Gun with TOW Missiles"
}
