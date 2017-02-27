//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutApache extends Mutator;

var class<ONSVehicle> TankVehicle1;
var class<ONSVehicle> TankVehicle2;
var class<ONSVehicle> TankReplacement1;
var class<ONSVehicle> TankReplacement2;
var GameObjective TeamBase[2];


function PostBeginPlay()
{
    if(SetTeamBases()){
        ReplaceVehicles();
    };
    Super.PostBeginPlay();
}

function ReplaceVehicles(){
    local ONSVehicleFactory   FactoryListRed[20];
    local ONSVehicleFactory   FactoryListBlu[20];
    local float FactoryListDistRed[20];
    local float FactoryListDistBlu[20];

    local ONSVehicleFactory FactoryTemp;
    local float FactoryDistTemp;

    local int FactoryListRedCount;
    local int FactoryListBluCount;
    //local class<ONSVehicle> Vehicle;
    local ONSVehicleFactory Factory;
    local int i,j;

    local bool isEven;

    FactoryListRedCount = 0;
    FactoryListBluCount = 0;
    // Create List
    foreach AllActors( class 'ONSVehicleFactory', Factory )
    {
        if(Factory.VehicleClass == TankVehicle1){
            if (VSize(Factory.Location - TeamBase[0].Location)
                    > VSize(Factory.Location - TeamBase[1].Location)){
                FactoryListRed[FactoryListRedCount] = Factory;
                FactoryListDistRed[FactoryListRedCount] = VSize(Factory.Location - TeamBase[0].Location);
                FactoryListRedCount++;
            }else{
                FactoryListBlu[FactoryListBluCount] = Factory;
                FactoryListDistBlu[FactoryListBluCount] = VSize(Factory.Location - TeamBase[1].Location);
                FactoryListBluCount++;
            }
        }
    }

    // sort
    for(i=0;i<FactoryListRedCount-2;i++){
        for(j=i+1;j<FactoryListRedCount-1;j++){
            if(FactoryListDistRed[i]>FactoryListDistRed[j]){
                FactoryDistTemp = FactoryListDistRed[i];
                FactoryListDistRed[i] = FactoryListDistRed[j];
                FactoryListDistRed[j] = FactoryDistTemp;
                FactoryTemp = FactoryListRed[i];
                FactoryListRed[j] = FactoryListRed[i];
                FactoryListRed[i] = FactoryTemp;
            }
        }
    }
    for(i=0;i<FactoryListBluCount-2;i++){
        for(j=i+1;j<FactoryListBluCount-1;j++){
            if(FactoryListDistBlu[i]>FactoryListDistBlu[j]){
                FactoryDistTemp = FactoryListDistBlu[i];
                FactoryListDistBlu[i] = FactoryListDistBlu[j];
                FactoryListDistBlu[j] = FactoryDistTemp;
                FactoryTemp = FactoryListBlu[i];
                FactoryListBlu[j] = FactoryListBlu[i];
                FactoryListBlu[i] = FactoryTemp;
            }
        }
    }
    // Assign Every Other
    isEven = true;
    for(i=0;i<FactoryListRedCount; i++){
        if(isEven){
            FactoryListRed[i].VehicleClass = TankReplacement1;
        }else{
            FactoryListRed[i].VehicleClass = TankReplacement2;
        }
        isEven = !isEven;
    }

    isEven = true;
    for(i=0;i<FactoryListBluCount; i++){
        if(isEven){
            FactoryListBlu[i].VehicleClass = TankReplacement1;
        }else{
            FactoryListBlu[i].VehicleClass = TankReplacement2;
        }
        isEven = !isEven;
    }
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
            else  if (CTFBase(O) != None /* || XBombDelivery(O) != None*/)
                TeamBase[O.DefenderTeamIndex]=O;
                /*
            else if (xDomPointA(O) != None)
                TeamBase[0]=O;
            else if (xDomPointB(O) != None)
                TeamBase[1]=O;
                */
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

DefaultProperties
{
    bAddToServerPackages=True
    TankVehicle1=class'Onslaught.ONSAttackCraft'

    TankReplacement1=class'Onslaught.ONSAttackCraft'
    TankReplacement2=class'WumpusASVehicles.Apache'

    GroupName="Raptor"
    FriendlyName="Raptor and Apache"
    Description="Replaces every other Raptor with Apache."
}
