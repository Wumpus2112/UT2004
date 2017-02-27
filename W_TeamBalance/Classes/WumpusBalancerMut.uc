//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WumpusBalancerMut extends Mutator
    dependson(WumpusBalancerStatsData)
    config(WumpusBalancerStatsData);

    var config WumpusBalancerStatsData wtStats;

    var bool bInitialized;
    var bool bGameInProgress;
    var bool bPickTeams;

    struct WTPlayer{
        var string PlayerName;
        var int    PlayerScore;
        var int    PlayerTeamNumber;
        var bool   bMovedToTeam;
    };

    var WTPlayer WTPlayers[32];
    var int    PlayerArraySize;

    var int    iPlayerMiniumScore;
    var config bool isLogOn;

function PostBeginPlay(){
    if(isLogOn) log("-- WT -- PostBeginPlay");
    wtStats = new (None) class'WumpusBalancerStatsData';
    super.PostBeginPlay();
}

// ************ Init stuff - Start ****************

function Initialize(){
    if(isLogOn) log("-- WT -- Init");
    if(!isLogOn) log("-- WT -- LOG OFF");

    bInitialized = true;
    bGameInProgress = false;

    if(TeamGame(Level.Game) == none){
        bPickTeams = false;
        return;
    }

    if(TeamGame(Level.Game).bPlayersVsBots == true){
        bPickTeams = false;
        return;
    }

    bPickTeams=true;
    PlayerArraySize=0;

    if(isLogOn) log("-- WT -- Init Complete");
}

function LogPlayerlist(){
    local int i;
    if(!isLogOn){
        return;
    }

    log("-- WT -- LogPlayerlist -- Total Players: "$PlayerArraySize);

    log("-- WT -- LogPlayerlist -- RED TEAM: "$getTeamRank(0));
    for(i=0; i < PlayerArraySize ; i++){
        if(WTPlayers[i].PlayerTeamNumber == 0){
             log("-- WT -- LogPlayerlist --   "$WTPlayers[i].PlayerName$" - "$WTPlayers[i].PlayerScore);
        }
    }

    log("-- WT -- LogPlayerlist -- BLUE TEAM: "$getTeamRank(1));
    for(i=0; i < PlayerArraySize ; i++){
        if(WTPlayers[i].PlayerTeamNumber == 1){
             log("-- WT -- LogPlayerlist --   "$WTPlayers[i].PlayerName$" - "$WTPlayers[i].PlayerScore);
        }
    }
    log("-- WT -- LogPlayerlist ~~~~~~~~~~~~~");
}

function ModifyPlayer(Pawn Other){
    if(isLogOn) log("-- WT -- ModifyPlayer");

    bGameInProgress=true;

    if(!Other.PlayerReplicationInfo.bBot){
        PlayerControllerCheckTeam(Other.Controller);
    }

    super.ModifyPlayer(Other);
}

function ModifyLogin (out string Portal, out string Options){
    local String sNick;
    local int lowTeamNumber;
    local int playerScore;
    local int i;

    /* Player Entered Match can happen before initialize */
    if(!bInitialized) Initialize();

    if(isLogOn) log("-- WT -- ModifyLogin");

    sNick = Level.Game.ParseOption(Options,"name");

    super.ModifyLogin(Portal,Options);

    i = GetPlayerIndex(sNick);
    if(i<0){
        if(isLogOn) log("-- WT -- Adding player:"$sNick);
        playerScore=GetPlayerScore(sNick);
        lowTeamNumber = GetSmallerTeam();
        AddPlayer(sNick,playerScore,lowTeamNumber);
    }

    if(!bGameInProgress && bInitialized){
        BalanceTeams();
    }else{
         log("-- WT -- GAME STARTED");
    }
}

function BalanceTeams(){
    local int iRedPlayerIndex, iBluePlayerIndex;
    local int iBlueRank, iRedRank;

    log("-- WT -- BALANCE TEAMS");

    if(PlayerArraySize>4){
        iRedRank = getTeamRank(0);
        iBlueRank = getTeamRank(1);


        // Blue is High
        if(iBlueRank-3 > iRedRank){
            iRedPlayerIndex = FindLowRankPLayer(0);
            iBluePlayerIndex = FindHighRankPLayer(1);
        }

        // Red is High
        if(iBlueRank < iRedRank-3){
            iRedPlayerIndex = FindHighRankPLayer(1);
            iBluePlayerIndex = FindLowRankPLayer(0);
        }

        if(iRedPlayerIndex > -1 && iBluePlayerIndex > -1){
            WTPlayers[iRedPlayerIndex].PlayerTeamNumber=1;
            WTPlayers[iBluePlayerIndex].PlayerTeamNumber=0;
        }
    }

    MovePlayers();
    LogPlayerlist();
}

function int FindHighRankPlayer(int iTeam){
    local int i,j,k;

    for(i=0; i < PlayerArraySize ; i++){
        if(WTPlayers[i].PlayerTeamNumber == iTeam && WTPlayers[i].PlayerScore > 5){
            for(j=0;j<20;j++){
                k=Rand(PlayerArraySize);
                if(WTPlayers[k].PlayerTeamNumber == iTeam && WTPlayers[i].PlayerScore > 5){
                    return k;
                }
            }
            return i;
        }
    }

    return -1;
}

function int FindLowRankPlayer(int iTeam){
    local int i,j,k;

    for(i=0; i < PlayerArraySize ; i++){
        if(WTPlayers[i].PlayerTeamNumber == iTeam && WTPlayers[i].PlayerScore < 5){
            for(j=0;j<20;j++){
                k=Rand(PlayerArraySize);
                if(WTPlayers[k].PlayerTeamNumber == iTeam && WTPlayers[i].PlayerScore < 5){
                    return k;
                }
            }
            return i;
        }
    }

    return -1;
}

function int GetSmallerTeam(){
    local int redSize, blueSize, redRank, blueRank;

    redSize = getTeamSize(0);
    blueSize = getTeamSize(1);

    redRank = getTeamRank(0);
    blueRank = getTeamRank(1);

    if(isLogOn) log("-- WT -- GetSmallerTeam (Rank) - Blue: "$blueRank$" Red: "$redRank);
    if(isLogOn) log("-- WT -- GetSmallerTeam (Size) - Blue: "$blueSize$" Red: "$redSize);

    // Example:
    /*
        Red has 10(11), Blue has 10, Blue Has Lower Rank: (11>10) true Add to blue (Blue will be 11), Hope this balances
        Red has 9 (10), Blue has 10, Blue Has Lower Rank: (10>10) false add to red (Red will be 10), Let Balance move people
    */
    if( (blueRank < redRank) && ( (redSize+1) > blueSize ) ){
        if(isLogOn) log("-- WT -- Smaller Team BLUE");
        return 1;
    }

    if(isLogOn) log("-- WT -- Smaller Team RED");
    return 0;
}

function int getTeamRank(int iTeam){
    local int i, teamRank;

    teamRank=0;

    for(i=0; i < PlayerArraySize ; i++){
        if(WTPlayers[i].PlayerTeamNumber ==iTeam){
            teamRank = teamRank + WTPlayers[i].PlayerScore;
        }
    }

    return teamRank;
}


function int getTeamSize(int iTeam){
    local int i, teamSize;

    teamSize=0;

    for(i=0; i < PlayerArraySize ; i++){
        if(WTPlayers[i].PlayerTeamNumber ==iTeam){
            teamSize++;
        }
    }

    return teamSize;
}


function MovePlayers(){
    local Controller C;

    for( C = Level.ControllerList; C != None; C = C.NextController ){
        if(C.PlayerReplicationInfo != none){
            PlayerControllerCheckTeam(C);
        }
    }

}

function PlayerControllerCheckTeam(Controller C){
    local int currTeamID, desiredTeamID, i;
    local String tempName;

    if(C.PlayerReplicationInfo.Team == none){
        if(isLogOn) log("-- WT -- Check Team - ERROR");
        return;
    }

    tempName = C.PlayerReplicationInfo.PlayerName;
    currTeamID = C.PlayerReplicationInfo.Team.TeamIndex;

    i = GetPlayerIndex(tempName);
    if(i<0) return;

    desiredTeamID = WTPlayers[i].PlayerTeamNumber;

    if(desiredTeamID != currTeamID && !WTPlayers[i].bMovedToTeam){
        TeamChange (C, desiredTeamID);
    }
    WTPlayers[i].bMovedToTeam=true;
}

function TeamChange (Controller C, int iTeam)
{
  if ( !C.PlayerReplicationInfo.bBot )
  {
    PlayerController(C).ChangeTeam(iTeam);
  }
}

// ************ During Play - Stop ****************




// ************ Util stuff - Start ****************

function AddPlayer(string AddPlayerName, int score, int iTeam){

     local WTPlayer newPlayer;
     newPlayer.PlayerName = AddPlayerName;

     newPlayer.PlayerScore = GetPlayerScore(AddPlayerName);
     newPlayer.PlayerTeamNumber=iTeam;
     newPlayer.bMovedToTeam=false;

     WTPlayers[PlayerArraySize] = newPlayer;
     PlayerArraySize++;
}


function int GetPlayerScore(String playerName){
    local int i;
    local string wtStatsName;
    local int statsNumPlayers;

    if(isLogOn) log("-- WT -- GetPlayerScore");
    statsNumPlayers = wtStats.getNumberOfPlayers();
    for(i=0; i < statsNumPlayers ; i++){
        wtStatsName = wtStats.GetPlayerName(i);
        if(wtStatsName == playerName){
            return wtStats.GetPlayerScore(i);
        }
    }
    return 1;
}

function int GetPlayerIndex(String PlayerName){
    local int i;

    for(i=0; i < PlayerArraySize; i++){
        if(PlayerName == WTPlayers[i].PlayerName) return i;
    }
    return -1;
}

// ************ Util stuff - Stop ****************


// ************ Persist - Start ****************

function SaveScores(){
    local Controller C;

    wtStats.Clear();

    for( C = Level.ControllerList; C != None; C = C.NextController ){
        if(C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bBot && C.PlayerReplicationInfo.PlayerName != "WebAdmin" && C.PlayerReplicationInfo.PlayerName != "DemoRecSpectator" ){
            wtStats.AddPlayer(C.PlayerReplicationInfo.PlayerName);
        }
    }
    wtStats.SaveSettings();
}

// ************ Persist - Stop ****************

defaultproperties
{
     isLogOn=True
     iPlayerMiniumScore=1

     bAddToServerPackages=True
     GroupName="TeamPicker"
     FriendlyName="Wumpus Team Balancer 1.0"
     Description="#Team picking#"
}
