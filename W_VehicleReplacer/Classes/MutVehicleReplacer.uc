//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutVehicleReplacer extends Mutator
     config (VehicleReplacer);

struct ReplacementData
{
    var string OrignalClassName;
    var class<Vehicle> ReplacementClass[2];
    var bool   flag;
};

var protected config array<ReplacementData> ReplacementList;

var GameObjective TeamBase[2];
var bool isChangeFactoryOwner;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    //saveMyConfig();
    isChangeFactoryOwner = GetIsChangeFactoryOwner();
    if(SetTeamBases()){
        ReplaceVehicles();
    };
}

function bool GetIsChangeFactoryOwner(){
     if(Level.LevelEnterText == "BRING IT ON PUNKS!") {
        log("-");
        log("Agressive Allleys: no replace!!!");
        log("-");
        return false;
    }else{
        return true;
    }
}

function ReplaceVehicles(){
    local array <ONSVehicleFactory> FactoryListRed;
    local array <ONSVehicleFactory> FactoryListBlu;
    local array <float> FactoryListDistRed;
    local array <float> FactoryListDistBlu;

    local ONSVehicleFactory FactoryTemp;
    local float FactoryDistTemp;

    local ONSVehicleFactory Factory;
    local int i,j;

    local int FactoryListRedCount;
    local int FactoryListBluCount;

    local class<Vehicle> tempVehicleClass;

    Log ("ReplaceVehicles-Begin");

    Log ("ReplaceVehicles-Create List");

     /*
    // Create Red/Blu List
    foreach AllActors( class 'ONSVehicleFactory', Factory )
    {
         if(0==Factory.TeamNum){
              FactoryListRed[FactoryListRedCount] = Factory;
              FactoryListDistRed[FactoryListRedCount] = VSize(Factory.Location - TeamBase[0].Location);
              FactoryListRedCount++;
         }else{
              FactoryListBlu[FactoryListBluCount] = Factory;
              FactoryListDistBlu[FactoryListBluCount] = VSize(Factory.Location - TeamBase[1].Location);
              FactoryListBluCount++;
         }
    }
    */
    foreach AllActors( class 'ONSVehicleFactory', Factory )
    {
            if (VSize(Factory.Location - TeamBase[0].Location)
                    < VSize(Factory.Location - TeamBase[1].Location)){
                if(isChangeFactoryOwner) Factory.TeamNum = 0;
                FactoryListRed[FactoryListRedCount] = Factory;
                FactoryListDistRed[FactoryListRedCount] = VSize(Factory.Location - TeamBase[0].Location);
                FactoryListRedCount++;
            }else{
                if(isChangeFactoryOwner) Factory.TeamNum = 1;
                FactoryListBlu[FactoryListBluCount] = Factory;
                FactoryListDistBlu[FactoryListBluCount] = VSize(Factory.Location - TeamBase[1].Location);
                FactoryListBluCount++;
            }
    }

    // sort
    for(i=0;i<FactoryListRedCount-1;i++){
        for(j=i+1;j<FactoryListRedCount;j++){
            if(FactoryListDistRed[i]>FactoryListDistRed[j]){
                FactoryTemp = FactoryListRed[i];
                FactoryDistTemp = FactoryListDistRed[i];

                FactoryListRed[i] = FactoryListRed[j];
                FactoryListDistRed[i] = FactoryListDistRed[j];

                FactoryListRed[j] = FactoryTemp;
                FactoryListDistRed[j] = FactoryDistTemp;
            }
        }
    }

    for(i=0;i<FactoryListBluCount-1;i++){
        for(j=i+1;j<FactoryListBluCount;j++){
            if(FactoryListDistBlu[i]>FactoryListDistBlu[j]){
                FactoryTemp = FactoryListBlu[i];
                FactoryDistTemp = FactoryListDistBlu[i];

                FactoryListBlu[i] = FactoryListBlu[j];
                FactoryListDistBlu[i] = FactoryListDistBlu[j];

                FactoryListBlu[j] = FactoryTemp;
                FactoryListDistBlu[j] = FactoryDistTemp;
            }
        }
    }

    //reset flags
    for(i=0;i < ReplacementList.Length;i++)
    {
        ReplacementList[i].flag = false;
    }

    Log ("ReplaceVehicles-replace Red");
    // Assign Every Other Red
    for(i=0;i<FactoryListRedCount; i++){
        tempVehicleClass = getReplacementVehicleClass(FactoryListRed[i].VehicleClass);
     //   log(i$"-Red-"$FactoryListRed[i].VehicleClass$"<-"$tempVehicleClass);
        FactoryListRed[i].VehicleClass = tempVehicleClass;
    }

    //reset flags
    for(i=0;i < ReplacementList.Length;i++)
    {
        ReplacementList[i].flag = false;
    }

    Log ("ReplaceVehicles-replace Blu");
    // Assign Every Other Blu
    for(i=0; i<FactoryListBluCount; i++){
        tempVehicleClass = getReplacementVehicleClass(FactoryListBlu[i].VehicleClass);
       // log(i$"-Blu-"$FactoryListBlu[i].VehicleClass$"<-"$tempVehicleClass);
        FactoryListBlu[i].VehicleClass = tempVehicleClass;
    }
}

function saveMyConfig(){
/*
     //VehicleClassNames(0)="Onslaught.ONSRV"
     //VehicleClassNames(1)="Onslaught.ONSPRV"
     //VehicleClassNames(2)="Onslaught.ONSAttackCraft"
     //VehicleClassNames(3)="Onslaught.ONSHoverBike"
     //VehicleClassNames(4)="Onslaught.ONSHoverTank"
     //VehicleClassNames(5)="OnslaughtBP.ONSDualAttackCraft"
     //VehicleClassNames(6)="OnslaughtBP.ONSArtillery"
     //VehicleClassNames(7)="OnslaughtBP.ONSShockTank"

     ReplacementList.Insert(0,8);

     ReplacementList[0].OrignalClassName = "Onslaught.ONSRV";
     ReplacementList[0].ReplacementClass[0] = class'Onslaught.ONSRV';
     ReplacementList[0].ReplacementClass[1] = class'Onslaught.ONSRV';
     ReplacementList[0].flag = false;

     ReplacementList[1].OrignalClassName = "Onslaught.ONSPRV";
     ReplacementList[1].ReplacementClass[0] = class'Onslaught.ONSRV';
     ReplacementList[1].ReplacementClass[1] = class'Onslaught.ONSRV';
     ReplacementList[1].flag = false;

     ReplacementList[2].OrignalClassName = "Onslaught.ONSAttackCraft";
     ReplacementList[2].ReplacementClass[0] = class'Onslaught.ONSAttackCraft';
     ReplacementList[2].ReplacementClass[1] = class'Onslaught.ONSHoverBike';
     ReplacementList[2].flag = false;

     ReplacementList[3].OrignalClassName = "Onslaught.ONSHoverBike";
     ReplacementList[3].ReplacementClass[0] = class'Onslaught.ONSAttackCraft';
     ReplacementList[3].ReplacementClass[1] = class'Onslaught.ONSHoverBike';
     ReplacementList[3].flag = false;

    SaveConfig();
    Log ("ReplaceVehicles-Save config End");
*/
}

function class<Vehicle> getReplacementVehicleClass(class<Vehicle> vehicleClass){
     local int replacementIndex, replacementFlag;
     local class<Vehicle> replacementVehicleClass;

     replacementIndex = getVehicleClassNumber(vehicleClass);

     // not found, don't replace
     if(replacementIndex<0) return vehicleClass;

     replacementFlag = 0;
     if(ReplacementList[replacementIndex].flag){
         replacementFlag = 1;
     }
     ReplacementList[replacementIndex].flag =! ReplacementList[replacementIndex].flag;

     replacementVehicleClass = ReplacementList[replacementIndex].ReplacementClass[replacementFlag];

     if(replacementVehicleClass == None){
         Log ("ReplaceVehicles - ERROR - "$vehicleClass.Name$" replacement not a class (None) using orignal:"$vehicleClass.Name);
         replacementVehicleClass = vehicleClass;
     }

     return replacementVehicleClass;
}

function int getVehicleClassNumber(class<Vehicle>  vehicleClass){
     local int i;
     local class<Vehicle> parentVehicleClass;

     for(i=0;i < ReplacementList.Length;i++)
     {
          if(string(vehicleClass.Name) == ReplacementList[i].OrignalClassName){
               return i;
          }
     }

     for(i=0;i < ReplacementList.Length;i++)
     {
          if(string(vehicleClass.Name) == ReplacementList[i].OrignalClassName){
               return i;
          }
     }

     if(ReplacementList.Length == 9){

     /* check for custom vehicles (I should have put this in an array)*/
     Log ("ReplaceVehicles-Looking for custom class parent: "$vehicleClass.Name);

     parentVehicleClass = class'Onslaught.ONSRV';
     if(ClassIsChildOf(vehicleClass,parentVehicleClass)) return getVehicleClassNumber(parentVehicleClass);
     parentVehicleClass = class'Onslaught.ONSPRV';
     if(ClassIsChildOf(vehicleClass,parentVehicleClass)) return getVehicleClassNumber(parentVehicleClass);
     parentVehicleClass = class'OnslaughtBP.ONSDualAttackCraft';
     if(ClassIsChildOf(vehicleClass,parentVehicleClass)) return getVehicleClassNumber(parentVehicleClass);
     parentVehicleClass = class'Onslaught.ONSAttackCraft';
     if(ClassIsChildOf(vehicleClass,parentVehicleClass)) return getVehicleClassNumber(parentVehicleClass);
     parentVehicleClass = class'Onslaught.ONSHoverBike';
     if(ClassIsChildOf(vehicleClass,parentVehicleClass)) return getVehicleClassNumber(parentVehicleClass);
     parentVehicleClass = class'Onslaught.ONSHoverTank';
     if(ClassIsChildOf(vehicleClass,parentVehicleClass)) return getVehicleClassNumber(parentVehicleClass);
     parentVehicleClass = class'OnslaughtBP.ONSArtillery';
     if(ClassIsChildOf(vehicleClass,parentVehicleClass)) return getVehicleClassNumber(parentVehicleClass);
     parentVehicleClass = class'OnslaughtBP.ONSShockTank';
     if(ClassIsChildOf(vehicleClass,parentVehicleClass)) return getVehicleClassNumber(parentVehicleClass);
     parentVehicleClass = class'OnslaughtFull.ONSMobileAssaultStation';
     if(ClassIsChildOf(vehicleClass,parentVehicleClass)) return getVehicleClassNumber(parentVehicleClass);

     }
     Log ("ReplaceVehicles-Get class Number (End Error)"$vehicleClass.Name);

     return -1; // shouldn't get here, will use default replacement?
}

function bool SetTeamBases(){
    local bool bTeamGame;
    local GameObjective O;

    bTeamGame=(TeamGame(Level.Game) != none);
    // find the team base
    if (bTeamGame)
    {
        ForEach DynamicActors(class'GameObjective',O)
        {

            if (ONSPowerCoreRed(O) != None)
                TeamBase[0]=O;
            else if  (ONSPowerCoreBlue(O) != None)
                TeamBase[1]=O;
            else  if (CTFBase(O) != None || XBombDelivery(O) != None)
                TeamBase[O.DefenderTeamIndex]=O;
            else if (xDomPointA(O) != None)
                TeamBase[0]=O;
            else if (xDomPointB(O) != None)
                TeamBase[1]=O;
        }
        if (TeamBase[1] == None)
            ForEach AllActors(class'GameObjective',O)
            {
                if (O.DefenderTeamIndex < 2)
                    TeamBase[O.DefenderTeamIndex]=O;
            }
        if (TeamBase[1] == None || (TeamBase[1].DefenderTeamIndex == TeamBase[0].DefenderTeamIndex))
            bTeamGame=false;
    }

    return bTeamGame;
}

defaultproperties
{
     ReplacementList(0)=(OrignalClassName="ONSRV",ReplacementClass[0]=Class'W_ScorpionPlasma.ScorpionPlasma',ReplacementClass[1]=Class'W_Bike.Bike')
     ReplacementList(1)=(OrignalClassName="ONSPRV",ReplacementClass[0]=Class'W_AAHellbender.AAHellbender',ReplacementClass[1]=Class'W_Tumbler.Tumbler')
     ReplacementList(2)=(OrignalClassName="ONSAttackCraft",ReplacementClass[0]=Class'Onslaught.ONSAttackCraft',ReplacementClass[1]=Class'W_Phantom.Phantom')
     ReplacementList(3)=(OrignalClassName="ONSHoverBike",ReplacementClass[0]=Class'Onslaught.ONSHoverBike',ReplacementClass[1]=Class'Onslaught.ONSRV')
     ReplacementList(4)=(OrignalClassName="ONSHoverTank",ReplacementClass[0]=Class'Onslaught.ONSHoverTank',ReplacementClass[1]=Class'W_IonTank.IonTank')
     ReplacementList(5)=(OrignalClassName="ONSDualAttackCraft",ReplacementClass[0]=Class'W_Apache.Apache',ReplacementClass[1]=Class'OnslaughtBP.ONSDualAttackCraft')
     ReplacementList(6)=(OrignalClassName="ONSArtillery",ReplacementClass[0]=Class'OnslaughtBP.ONSArtillery',ReplacementClass[1]=Class'W_Stryker.Stryker')
     ReplacementList(7)=(OrignalClassName="ONSShockTank",ReplacementClass[0]=Class'OnslaughtBP.ONSShockTank',ReplacementClass[1]=Class'Onslaught.ONSRV')
     ReplacementList(8)=(OrignalClassName="ONSMobileAssaultStation",ReplacementClass[0]=Class'W_APC.APC',ReplacementClass[1]=Class'Onslaught.ONSRV')
     bAddToServerPackages=True
     GroupName="VehicleArena"
     FriendlyName="W_Vehicle Replacer"
     Description="Replace all vehicles in map with other kinds."
}
