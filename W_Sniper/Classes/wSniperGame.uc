//-----------------------------------------------------------
//
//-----------------------------------------------------------
class wSniperGame extends wTeamGame;

struct PlayerFireData
{
    var string PlayerName;
    var int PlayerTeam;
    var int PlayerTimer;
    var vector PlayerLocation;
};

var protected config array<PlayerFireData> PlayerFireList;

state MatchInProgress
{
    event Timer()
    {
        Super.Timer(); // Need this!!!
        UpdateLocations();
    }
}

simulated function UpdateLocations(){
    local Controller C;
    local WumpusRadarSniperGameReplicationInfo radarGRI;
    local int i;
    local vector blankLocation;
    local xWumpusRadarPawn radarPawn;
    local int playerIndex;

    radarGRI = WumpusRadarSniperGameReplicationInfo(GameReplicationInfo);

    for( C = Level.ControllerList; C != None; C = C.NextController ){
        if(C != none && C.PlayerReplicationInfo != none && C.Pawn != none){
                radarPawn = xWumpusRadarPawn(C.Pawn);
                if(radarPawn == None){
                    playerIndex = getFiringPlayer(C.PlayerReplicationInfo.PlayerName);
                    PlayerFireList[playerIndex].PlayerTimer = -1;
                }else{
                    if(radarPawn.bWumpusProtect){
                        playerIndex = getFiringPlayer(C.PlayerReplicationInfo.PlayerName);
                        PlayerFireList[playerIndex].PlayerTimer = -1;
                    }
                    if(radarPawn.bWumpusFiring){
                        addFiringPLayer(C);
                    }
                }
        }
    }

    removeNonFiringPlayers();

    for(i=0;i<16;i++){
        if(i<PlayerFireList.Length){
            radarGRI.PlayerName[i] = PlayerFireList[i].PlayerName;
            radarGRI.PlayerTeam[i] = PlayerFireList[i].PlayerTeam;
            radarGRI.PlayerLocation[i] = PlayerFireList[i].PlayerLocation;
        }else{
            radarGRI.PlayerName[i] = "-";
            radarGRI.PlayerTeam[i] = 2;
            radarGRI.PlayerLocation[i] = blankLocation;
        }

    }
}


function addFiringPLayer(Controller C){
     local int playerIndex;

     playerIndex = getFiringPlayer(C.PlayerReplicationInfo.PlayerName);
     PlayerFireList[playerIndex].PlayerTimer=5;
     PlayerFireList[playerIndex].PlayerTeam=C.PlayerReplicationInfo.Team.TeamIndex;
     PlayerFireList[playerIndex].PlayerLocation = C.Pawn.Location;
}



function int getFiringPlayer(String PlayerName){
     local int i;

     for(i=0;i<PlayerFireList.Length;i++){
          if(PlayerFireList[i].PlayerName==PlayerName) return i;
     }

     PlayerFireList.Insert(0,1);
     PlayerFireList[0].PlayerName = PlayerName;

     return 0;
}

function removeNonFiringPlayers(){

     local int i;

     for(i=0;i<PlayerFireList.Length;i++){
          PlayerFireList[i].PlayerTimer--;
          if(PlayerFireList[i].PlayerTimer < 0){
               PlayerFireList.Remove(i,1);
          }
     }
}


event PlayerController Login( string Portal, string Options, out string Error ){
    local PlayerController pc;

    pc = super.Login(Portal, Options, Error);

    if(pc != None){
        pc.PawnClass = class'W_Sniper.xWumpusRadarPawn';
    }

    return pc;
}

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{

    return super.ChangeTeam(Other,num,bNewTeam);
}


// Set bot pawn class
function Bot SpawnBot(optional string botName){
    local Bot B;

    B = super.SpawnBot(botName);

    if(B != None){
        B.PawnClass = class'W_Sniper.xWumpusRadarPawn';
    }
    return B;
}


defaultproperties
{
     HUDType="W_Sniper.HudRadarSniper"
     MutatorClass="W_Sniper.MutWumpusSniper"
     ResetTimeDelay=11
     GameReplicationInfoClass=Class'W_Sniper.WumpusRadarSniperGameReplicationInfo'
     GameName="Sniper Team Deathmatch"
     Description="W Sniper Team Deathmatch*"
     Acronym="STDM"

     bForceDefaultCharacter=true
}
