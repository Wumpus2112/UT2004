//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSVehicleRotatorFactory extends ONSVehicleFactory;

    var localized bool bDebugMode;
    var class<Vehicle> OrignalVehicleClass;

    struct VehicleReplacement
    {
        var class<Vehicle> ReplacementClass;
    };
    var array<VehicleReplacement> VehicleReplacementList;

    var int IndexReplacement;



function SpawnVehicle()
{
    VehicleClass = VehicleReplacementList[IndexReplacement].ReplacementClass;

    IndexReplacement = IndexReplacement + 1;

    if(IndexReplacement > VehicleReplacementList.Length -1){
        IndexReplacement = 0;
    }

    super.SpawnVehicle();
}

function AddVehicle(class<Vehicle> vClass){
     local int vehicleIndex;

     vehicleIndex = VehicleReplacementList.length;
     if(vehicleIndex == 0){
         VehicleClass = vClass;
         IndexReplacement = 0;
     }
     VehicleReplacementList.Insert(vehicleIndex,1);
     VehicleReplacementList[vehicleIndex].ReplacementClass = vClass;
}

static final function ONSVehicleRotatorFactory ReplaceWithVRF(Actor Other)
{
    local ONSVehicleFactory OldBase;
    local ONSVehicleRotatorFactory NewVRF;
    local class<ONSVehicleRotatorFactory> VRFClass;

    if(ONSVehicleFactory(Other) == none)
    {
        return none;
    }

    OldBase = ONSVehicleFactory(Other);

    VRFClass = class'ONSVehicleRotatorFactory';

    if( InStr(string(OldBase.Name),"Neutral") > -1 ){
        VRFClass = class'ONSNeutralVehicleRotatorFactory';
    }

//    if(Other.IsA('ONSVehicleFactory'))
//    {
        NewVRF = Other.Spawn(VRFClass, Other.Owner, Other.Tag, Other.Location, Other.Rotation);
//    }

    if(NewVRF == none)
    {
        Log("ReplaceVRF: Couldn't spawn new" @ string(VRFClass), 'ONSVehicleRotatorFactory');
        return none;
    }

    if(OldBase != none)
    {
        NewVRF.myMarker = OldBase.myMarker;
        NewVRF.RespawnTime = OldBase.RespawnTime;
        OldBase.myMarker = none;
        NewVRF.OrignalVehicleClass = OldBase.VehicleClass;

    }

    ///NewVRF.SetCollision(false, false, false);
    return NewVRF;
}





DefaultProperties
{
/*
     RedBuildEffectClass=Class'Onslaught.ONSRVBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSRVBuildEffectBlue'
     VehicleClass=Class'Onslaught.ONSRV'
     Mesh=SkeletalMesh'ONSVehicles-A.RV
*/

/*
    Mesh=Mesh'ONSVehicles-A.PRVchassis'
    VehicleClass=class'W_AAHellbender.AAHellbender'
    RedBuildEffectClass=class'ONSPRVBuildEffectRed'
    BlueBuildEffectClass=class'ONSPRVBuildEffectBlue'
*/
     bDebugMode=true

     RedBuildEffectClass=Class'Onslaught.ONSRVBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSRVBuildEffectBlue'
     VehicleClass=Class'Onslaught.ONSRV'
     Mesh=SkeletalMesh'ONSVehicles-A.RV'

     bNoDelete=false
}
