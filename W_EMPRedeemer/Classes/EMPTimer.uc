class EMPTimer extends Info;

#exec OBJ LOAD FILE=PickupSounds.uax

var int DisabledSecondsCount;

var array<Vehicle> VehicleList;


function Timer()
{
    DisabledSecondsCount--;
    if(DisabledSecondsCount<0){
        EnableVehicles();
	}
}

function AddVehicle(Vehicle AffectedVehicle){
    AffectedVehicle.EjectDriver();
    AffectedVehicle.bTeamLocked = true;
    AffectedVehicle.Team=3;
    VehicleList.Insert(0,1);
    VehicleList[0]=AffectedVehicle;
    //ONSFreeRoamingEnergyEffect
    //NewIonEffect?
    //IonCannonDeathEffect?
    //FX_Turret_IonCannon_BeamExplosion
}

function EnableVehicles(){
        local int i;
        local Vehicle AffectedVehicle;

         for(i=0;i < VehicleList.Length;i++)
         {
             AffectedVehicle = VehicleList[i];
             AffectedVehicle.bTeamLocked = false;
        }
    	Destroy();
}

defaultproperties
{
     DisabledSecondsCount=10
}
