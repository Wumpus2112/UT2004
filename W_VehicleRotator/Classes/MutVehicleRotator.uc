//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutVehicleRotator extends Mutator
     config (VehicleRotator);

struct ReplacementData
{
    var string OrignalClassName;
    var class<Vehicle> ReplacementClass[4];
};

var protected config array<ReplacementData> ReplacementList;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    DeactivateAllVehicleFactories();
}

function DeactivateAllVehicleFactories(){
    local ONSVehicleFactory Factory;

    foreach AllActors( class 'ONSVehicleFactory', Factory )
    {
        Factory.bActive = False;
        Factory.bNeverActivate=true;
        Factory.bPreSpawn = false;

    }
}


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if(Other.IsA('ONSVehicleFactory'))
    {
        return CheckONSVehicleFactory(ONSVehicleFactory(Other), bSuperRelevant);
    }

    return super.CheckReplacement(Other, bSuperRelevant);
}

function bool CheckONSVehicleFactory(ONSVehicleFactory Other, out byte bSuperRelevant)
{
    local ONSVehicleRotatorFactory VRF;

    if(Other.IsA('ONSVehicleRotatorFactory')){
        return true; // verified
    }

    if(Other.IsA('ONSVehicleFactory'))
    {
        VRF = ReplaceWithVRF(Other);
        AddVehiclesToRotatorFactory(VRF);
    }

    return false;
}

function AddVehiclesToRotatorFactory(ONSVehicleRotatorFactory VRF){
    local int i,j;

    for(i=0;i<ReplacementList.length;i++){
        if(string(VRF.OrignalVehicleClass) == ReplacementList[i].OrignalClassName){
            for(j=0;j<4;j++){
                if(ReplacementList[i].ReplacementClass[j] != none){
                    VRF.AddVehicle(ReplacementList[i].ReplacementClass[j]);
                }
            }
            return;
        }
    }

    log("Vehicle class not found:"@VRF.OrignalVehicleClass);
    VRF.AddVehicle(VRF.OrignalVehicleClass);
}




function ONSVehicleRotatorFactory ReplaceWithVRF(Actor Other)
{
    return class'ONSVehicleRotatorFactory'.static.ReplaceWithVRF(Other);
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="VehicleArena"
     FriendlyName="W Vehicle rotator 0.2"
     Description="Rotates the vehicles spawned from a vehicle factory"
}
