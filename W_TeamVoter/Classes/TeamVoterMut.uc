//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TeamVoterMut extends Mutator
    dependson(WumpusTeamsStatsData)
    config (W_TeamVoterMut);

    var WumpusTeamsStatsData  wtStats;
    var() editconst noexport WumpusTeamsReplicationInfo   wtrInfo;

    var bool bInitialized;

    var bool bAvailableOnly;
    var bool bScoresSaved;
    var bool bPickTeams;
    var bool bVoteInProcess;
    var bool bVotingDone;

    var bool bRecording;

    var int  iVoteLagTime;

    var int timeTilAutoPick;

    struct WTPlayer{
        var string PlayerName;
        var int    PlayerScore;
        var int    PlayerTeamNumberRequested;
        var int    PlayerTeamNumberActual;
        var bool   PlayerBalanceFlag;
        var int    PlayerMenuOpen;
        var bool   isLoggedIn;
        var bool   isCaptain;
    };
    var array<WTPlayer> WTPlayerList;
//    var WTPlayer WTPlayers[32];

    // config vars
    var config bool isSaveBots;
    var config bool isAutoPickBots;
    var config int  defaultAutoPick;
    var config bool isLogOn;
    var int  FailsafeTimer;

event Tick (float DeltaTime){
    if(!bInitialized){
        Initialize();
        bInitialized = true;
    }

    if(Level.Game.bGameEnded && !bScoresSaved){
        SaveScores();
        bScoresSaved = true;
    }

}

// ************ Init stuff - Start ****************

function Initialize(){


    if(isLogOn) log("-- WT -- Init");

    wtStats = Spawn(class'WumpusTeamsStatsData');

    if(TeamGame(Level.Game) == none){
        bPickTeams = false;
        EndVoting();
        return;
    }

    if(TeamGame(Level.Game).bPlayersVsBots == true){
        bPickTeams = false;
        EndVoting();
        return;
    }

    bVoteInProcess = false;
    bVotingDone = false;
    wtrInfo = Spawn(class'WumpusTeamsReplicationInfo');

    bRecording = false;


    bAvailableOnly = false;
    LoadPlayerList();

    // Turn on voting
    bVoteInProcess = true;
    SetTimer(1.0,true);

    if(isLogOn) log("-- WT -- Init Complete");
}

function LoadPlayerList(){

    if(isLogOn) log("-- WT -- LoadPlayerList: Start");
    if(WTPlayerList.length>0) WTPlayerList.Remove(0,WTPlayerList.length);

    if(isLogOn) log("-- WT -- LoadPlayerList: Load Controllers");
    LoadPlayerControllers();
    if(isLogOn) LogPlayerlist();

    if(!bAvailableOnly){
        if(isLogOn) log("-- WT -- LoadPlayerList: Load File");
        LoadPlayerFile();
        if(isLogOn) LogPlayerlist();
    }else{
        if(isLogOn) log("-- WT -- LoadPlayerList: NOT Loading File");
    }

    if(isLogOn) log("-- WT -- LoadPlayerList: Sort");
    SortPlayers();
    if(isLogOn) LogPlayerlist();

    if(isLogOn) log("-- WT -- LoadPlayerList: Assign Captains");

    if(getNumberOfUnassignedPlayers() < 2){
        EndVoting();
        return;
    }

    // Blue Team Captain
    WTPlayerList[1].isCaptain = true;
    WTPlayerList[1].PlayerTeamNumberRequested = 1;

    // Red Team Captain
    WTPlayerList[0].isCaptain = true;
    WTPlayerList[0].PlayerTeamNumberRequested = 0;

    CheckTeamPlayers();

    // BLUE Team Picks first
    wtrInfo.CurrentCaptain = 1;
    wtrInfo.PickingStatus = 1;
    timeTilAutoPick = defaultAutoPick*2;

    synchReplicationInfo();

    if(isLogOn) LogPlayerlist();
    if(isLogOn) log("-- WT -- Load PlayerList: End");

}

function synchReplicationInfo(){
    local int i;

    wtrInfo.RedCount=0;
    wtrInfo.BlueCount=0;
    wtrInfo.GreyCount=0;

    for(i=0; i< WTPlayerList.length;i++){
        if(WTPlayerList[i].PlayerTeamNumberRequested == 0){
            //Red Team
            if(WTPlayerList[i].isCaptain){
                wtrInfo.RedCaptainName = WTPlayerList[i].PlayerName;
            }else{
                wtrInfo.RedTeam[wtrInfo.RedCount] = WTPlayerList[i].PlayerName;
                wtrInfo.RedCount++;
            }

        }

        if(WTPlayerList[i].PlayerTeamNumberRequested == 1){
            if(WTPlayerList[i].isCaptain){
                wtrInfo.BlueCaptainName = WTPlayerList[i].PlayerName;
            }else{
                wtrInfo.BlueTeam[wtrInfo.BlueCount] = WTPlayerList[i].PlayerName;
                wtrInfo.BlueCount++;
            }

        }

        if(WTPlayerList[i].PlayerTeamNumberRequested < 0){
            wtrInfo.GreyTeam[wtrInfo.GreyCount] = WTPlayerList[i].PlayerName;
            wtrInfo.GreyCount++;
        }

    }

}

function LogPlayerlist(){
    if(!isLogOn) return;

    OutputPlayerlist();

}

function OutputPlayerlist(){
    local int i;

    log("-- WT -- LogPlayerlist ----------");

    for(i=0; i < WTPlayerList.length ; i++){
        log("-- WT -- LogPlayerlist Name:"$WTPlayerList[i].PlayerName$"Capt:"$WTPlayerList[i].isCaptain$" LogIn:["$WTPlayerList[i].isLoggedIn$"]" );
        log("-- WT -- LogPlayerlist R/B Pick:["$WTPlayerList[i].PlayerTeamNumberRequested$"] R/B Actual:["$WTPlayerList[i].PlayerTeamNumberActual$"] Balanced:["$WTPlayerList[i].PlayerBalanceFlag$"]");
    }

    log("-- WT -- LogPlayerlist ~~~~~~~~~~~~~");
}

function LoadPlayerFile(){
    local int i, newPlayerIndex, existingPlayer;

    if(isLogOn) log("-- WT -- LoadPlayerFile");
    for(i=0; i < wtStats.getNumberOfPlayers() ; i++){
        if(Right(wtStats.GetPlayerName(i),1) != "*"){
            existingPlayer = GetPlayerIndexByName(wtStats.GetPlayerName(i));
            if(existingPlayer < 0){
                newPlayerIndex = AddPlayer(wtStats.GetPlayerName(i));
                WTPlayerList[newPlayerIndex].PlayerScore = wtStats.GetPlayerScore(i);
            }else{
                WTPlayerList[existingPlayer].PlayerScore = wtStats.GetPlayerScore(i);
            }
        }
    }
}

function LoadPlayerControllers(){
    local int i;
    local bool isFound;
    local Controller C;

    if(isLogOn) log("-- WT -- LoadPlayerControllers: Start");

    for( C = Level.ControllerList; C != None; C = C.NextController ){

        if(isLogOn) log("-- WT -- LoadPlayerControllers: Check for Player Controller");

        if(C.PlayerReplicationInfo != none){

            for(i=0; i < WTPlayerList.length && !isFound; i++){
                isFound = (WTPlayerList[i].PlayerName == C.PlayerReplicationInfo.PlayerName);
            }

            if(isFound){
                WTPlayerList[i].isLoggedIn = true;
            }else{
                AddPlayer(C.PlayerReplicationInfo.PlayerName);
            }


        }// end player replication info

    }// end controllers
    if(isLogOn) log("-- WT -- LoadPlayerControllers: End");

}

function SortPlayers(){
    local int i,j;
    local WTPlayer tempPlayer;

    if(isLogOn) log("-- WT -- SortPlayers");

    for(i=0; i < WTPlayerList.length-1; i++){
        for(j=i+1; j < WTPlayerList.length ; j++){
            if(WTPlayerList[i].PlayerScore < WTPlayerList[j].PlayerScore){
                tempPlayer = WTPlayerList[i];
                WTPlayerList[i] = WTPlayerList[j];
                WTPlayerList[j] = tempPlayer;
            }
        }
    }
}

// ************ Init stuff - Stop ****************


event Timer(){

    if(bVoteInProcess){
        synchReplicationInfo();
        AutoPickCountdown();
        OpenTeamSelectionPage();
        CheckForAutopick();
        if(getNumberOfUnassignedPlayers() < 1) EndVoting();
    }else{
        EndVoting();
        SetTimer(0.0,false);
        if(PlayersAreAssigned()){
             if(isLogOn) log("-- WT -- Timer: Players Assigned");
        }else{
            if(isLogOn) log("-- WT -- Timer: Players NOT Assigned");
            ConsoleCommand("Warning not all players assigned.");
            ConsoleCommand("Type in Console: MUTATE WTEND");
        }
        LogPlayerlist();
    }
/*
    // no voting activity for 60 secs ....
    if(FailsafeTimer > 60){
        SetTimer(0.0,false);
        if(isLogOn) log("-- WT -- Timer: Failsafe Timer Expired");
    }
*/
}

function AutoPickCountdown(){
    iVoteLagTime--;
    if(iVoteLagTime > 0) return;
    wtrInfo.PickingStatus = 1;
    timeTilAutoPick--;
    wtrInfo.CountDown = timeTilAutoPick;
}

function CheckForAutopick(){
    local int unassignedIndex;

    // got it if we need it
    unassignedIndex= getUnassignedPlayerIndex();

    if(getNumberOfUnassignedPlayers() == 1){
        PickPlayer(unassignedIndex,GetSmallerTeamByVoting());
        if(isLogOn) log("-- WT -- CheckForAutopick final pick GetSmallerTeamByVoting() "@GetSmallerTeamByVoting());
        return;
    }

    // if bot red captain auto pick
    if(wtrInfo.CurrentCaptain == 0 && Right(wtrInfo.RedCaptainName,1) == "*"){
        PickPlayer(unassignedIndex,0);
        if(isLogOn) log("-- WT -- CheckForAutopick Bot pick Red");
        return;
    }
    // if bot blue captain auto pick
    if(wtrInfo.CurrentCaptain == 1 && Right(wtrInfo.BlueCaptainName,1) == "*"){
        PickPlayer(unassignedIndex,1);
        if(isLogOn) log("-- WT -- CheckForAutopick Bot pick Blue");
        return;
    }

    // human captain autopick, 3 secs just in case they picked last second
    if(timeTilAutoPick < -3){

        // if the captain isn't logged in, trim the file and restart
        if(!isCaptainLoggedInByTeamNumber(wtrInfo.CurrentCaptain)){
            bAvailableOnly=true;
            LoadPlayerList();
            return;
        }

        PickPlayer(unassignedIndex,wtrInfo.CurrentCaptain);
        if(isLogOn) log("-- WT -- CheckForAutopick timeout-AutoPick");
        return;
    }
}

function bool isCaptainLoggedInByTeamNumber(int teamNumber){
    local int i;

    for(i=0; i < WTPlayerList.length ; i++){
        if(WTPlayerList[i].PlayerTeamNumberRequested == teamNumber && WTPlayerList[i].isCaptain){
            return WTPlayerList[i].isLoggedIn;
        }
    }

    return false;
}

function bool isPlayerLoggedIn(String playerName){
    local int playerIndex;

    playerIndex = GetPlayerIndexByName(playerName);
    if(playerIndex<0) return false;

    return WTPlayerList[playerIndex].isLoggedIn;
}

function bool isPlayerAssignedTeam(int playerIndex){
    return WTPlayerList[playerIndex].PlayerTeamNumberRequested > -1;
}


function int getUnassignedPlayerIndex(){
     local int i;

     for(i=0; i < WTPlayerList.Length; i++){
          if(WTPlayerList[i].PlayerTeamNumberRequested < 0){
               return i;
          }
     }
     return -1;
}

function int getNumberOfUnassignedPlayers(){
     local int i, iUnassignedPlayers;

     iUnassignedPlayers = 0;
     for(i=0; i < WTPlayerList.Length; i++){
          if(WTPlayerList[i].PlayerTeamNumberRequested < 0){
               iUnassignedPlayers++;
          }
     }
     return iUnassignedPlayers;
}


function EndVoting(){
    if(isLogOn) log("-- WT -- EndVote Start");

    if(bVoteInProcess == true){
        if(isLogOn) log("-- WT -- Ending the Vote");
        bVotingDone = true;
        bVoteInProcess = false;
        CheckTeamPlayers();
        LogPlayerlist();
        CloseTeamSelectionPage();
        if(isLogOn) log("-- WT -- EndVote Complete");
    }else{
        bVotingDone = true;
        CheckTeamPlayers();
        OutputPlayerlist();
    }
}

function ModifyPlayer(Pawn Other){
    super.ModifyPlayer(Other);

//    if(isLogOn) log("-- WT -- ModifyPlayer >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

    if(PlayerController(Other.Controller) != none){
        CheckTeamPlayer(Other.Controller);
//        if(!bVotingDone) EndVoting();
    }

}

function ModifyLogin (out string Portal, out string Options){
    local String sNick;
    local int newPlayer;

    sNick = Level.Game.ParseOption(Options,"name");

    super.ModifyLogin(Portal,Options);

    newPlayer = GetPlayerIndexByName(sNick);
    if(newPlayer < 0){
        newPlayer = AddPlayer(sNick);
    }

    if( newPlayer < -1 ) return;
    WTPlayerList[newPlayer].isLoggedIn=true;

    if(!bVoteInProcess){
        AutoAssignPlayer(sNick);
    }

}

function int GetSmallerTeamByVoting(){
    local int i, red, blue;

    red = 0;
    blue = 0;

    for(i=0; i < WTPlayerList.length ; i++){
        if(WTPlayerList[i].PlayerTeamNumberRequested ==0){
            red++;
        }
        if(WTPlayerList[i].PlayerTeamNumberRequested ==1){
            blue++;
        }
    }

    if(isLogOn) log("-- WT -- GetSmallerTeamByVoting - Blue: "$blue$" Red: "$red);

    if(blue < red){
        return 1;
    }

    return 0;
}


function int GetSmallerTeamByControllers(){
    local int red,blue;
    local Controller C;

    red = 0;
    blue = 0;

    for( C = Level.ControllerList; C != none; C = C.NextController ){
        if(C.PlayerReplicationInfo != none && C.Pawn != none){
            if(C.PlayerReplicationInfo.Team.TeamIndex == 0){
                red++;
            }else{
                blue++;
            }
        }
    }

    if(blue<red){
        // blue is smaller
        return 1;
    }
    // red is smaller (or the same)
    return 0;
}

function bool PlayersAreAssigned(){
    local int i;

    CheckTeamPlayers();

    for(i=0; i < WTPlayerList.length ; i++){
        if(WTPlayerList[i].PlayerTeamNumberRequested != WTPlayerList[i].PlayerTeamNumberActual){
            return false;
        }
    }
    return true;
}

function CheckTeamPlayers(){
    local Controller C;

    for( C = Level.ControllerList; C != None; C = C.NextController ){
        if(C.PlayerReplicationInfo != none){
            CheckTeamPlayer(C);
        }
    }

}

function CheckTeamPlayer(Controller C){
    local int currTeamID;
    local String tempName;
    local int playerIndex;

    if(C.PlayerReplicationInfo == none) return;
    if(C.PlayerReplicationInfo.Team == none) return;
    if(C.PlayerReplicationInfo.bBot) return;


    tempName = C.PlayerReplicationInfo.PlayerName;
    playerIndex = GetPlayerIndexByName(tempName);

    if(playerIndex < 0){
        log("-- WT -- CheckTeamPlayer:"$tempName$" - NOT FOUND");
        return;
    }

    currTeamID = C.PlayerReplicationInfo.Team.TeamIndex;
    WTPlayerList[playerIndex].PlayerTeamNumberActual = currTeamID;

    if(WTPlayerList[playerIndex].PlayerBalanceFlag == true) return;

    if(WTPlayerList[playerIndex].PlayerTeamNumberActual != WTPlayerList[playerIndex].PlayerTeamNumberRequested){
        MovePlayer(C);
    }else{
        WTPlayerList[playerIndex].PlayerBalanceFlag=true;
    }
}

function MovePlayer(Controller C){
    local int currTeamID;
    local String tempName;
    local int playerIndex;
    local int iRequestedTeam;

    if(C.PlayerReplicationInfo == none) return;
    if(C.PlayerReplicationInfo.Team == none) return;

    tempName = C.PlayerReplicationInfo.PlayerName;

    playerIndex = GetPlayerIndexByName(tempName);
    iRequestedTeam = WTPlayerList[playerIndex].PlayerTeamNumberRequested;
    if ( !C.PlayerReplicationInfo.bBot && iRequestedTeam > -1 ){
        PlayerController(C).ChangeTeam(iRequestedTeam);
    }

    currTeamID = C.PlayerReplicationInfo.Team.TeamIndex;
    WTPlayerList[playerIndex].PlayerTeamNumberActual = currTeamID;

}

simulated function ChangePickingCaptain(int currentCaptain){
    if(isLogOn) log("-- WT -- ChangePickingCaptain");

    if(currentCaptain == 1){
        currentCaptain = 0;
    }else{
        currentCaptain = 1;
    }

    wtrInfo.CurrentCaptain = currentCaptain;
}

// ************ During Play - Stop ****************




// ************ Util stuff - Start ****************


function int CountPlayerControlers(){
    local int iNumPlayerControllers;
    local Controller C;

    iNumPlayerControllers = 0;
    for( C = Level.ControllerList; C != None; C = C.NextController ){
        if(C.PlayerReplicationInfo != none && C.Pawn != none){
            iNumPlayerControllers++;
        }
    }
    return iNumPlayerControllers;
}

function AutoAssignPlayer(string PlayerName){
    local int assignedTeam;
    local int playerIndex;

    playerIndex = GetPlayerIndexByName(PlayerName);
    WTPlayerList[playerIndex].PlayerTeamNumberRequested = assignedTeam;
}


function int AddPlayer(string AddPlayerName){

     local int newPlayerIndex;

     if(isLogOn) log("-- WT -- Add Player: Start");

     if(AddPlayerName == "WebAdmin") return -1;

     if(isBot(AddPlayerName)) return -1;

     if(isLogOn) log("-- WT -- Adding Player - "$AddPlayerName);

     newPlayerIndex = WTPlayerList.length;

     WTPlayerList.Insert(newPlayerIndex,1);
     WTPlayerList[newPlayerIndex].PlayerName = AddPlayerName;
     WTPlayerList[newPlayerIndex].PlayerTeamNumberRequested = -1;
     WTPlayerList[newPlayerIndex].PlayerTeamNumberActual = -1;
     WTPlayerList[newPlayerIndex].PlayerBalanceFlag = false;

     if(isLogOn) log("-- WT -- Add Player: End");

     return newPlayerIndex;
}

function bool isBot(string PlayerName){
    local Controller C;

    for( C = Level.ControllerList; C != None; C = C.NextController ){
        if(C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.PlayerName == PlayerName && C.PlayerReplicationInfo.bBot){
            return true;
        }
    }
    return false;
}

function int GetPlayerIndexByName(String PlayerName){
    local int i;

    for(i=0; i<WTPlayerList.Length;i++){
        if(WTPlayerlist[i].PlayerName == PlayerName) return i;
    }
    return -1;
}

// ************ Util stuff - Stop ****************

// ************ Vote stuff - Start ****************

// Voting Stuff

function PickPlayerByName(String pickedPlayerName, int iTeamNumber){
     local int pickedPlayerindex;
     pickedPlayerindex = GetPlayerIndexByName(pickedPlayerName);
     PickPlayer(pickedPlayerindex, iTeamNumber);
}


function PickPlayer(int pickedPlayerIndex, int iTeamNumber){

    if(isLogOn) log("-- WT -- PickPlayerIndex Start: "@WTPlayerList[pickedPlayerIndex].PlayerName@" - "@iTeamNumber);

    if(!isPlayerAssignedTeam(pickedPlayerIndex)){

        if(iTeamNumber == 0 || iTeamNumber == 1){
//            AssignPlayer(pickedPlayerIndex,iTeamNumber);
            WTPlayerList[pickedPlayerIndex].PlayerTeamNumberRequested = iTeamNumber;
        }

        ChangePickingCaptain(iTeamNumber);
        timeTilAutoPick = defaultAutoPick;
    }else{
        if(isLogOn) log("-- WT -- PickPlayerIndex ERROR ALREADY ASSIGNED: "@WTPlayerList[pickedPlayerIndex].PlayerName@" - "@WTPlayerList[pickedPlayerIndex].PlayerTeamNumberRequested);
    }
}

// ************ Vote GUI - Start ****************
function Mutate (string MutateString, PlayerController Sender){
    local String selectedPlayer;
    local int    iTeamNumber;
    local String pingedPlayer;
    local int failSafeCounter;

//    if(isLogOn) log("-- WT -- Mutate Message: "@MutateString);

    //WTSELECT=XPLAYERNAME | x = team is | playername = playername
    if(Left(MutateString,9) == "WTSELECT="){
        selectedPlayer = Mid(MutateString,10);
        iTeamNumber = Asc(Mid(MutateString,9,1)) - 48;
        PickPlayerByName(selectedPlayer, iTeamNumber);
    }

    //PING=PLAYERNAME | if we don't get pings, a voting screen isn't up
    if(Left(MutateString,7) == "WTPING="){
        pingedPlayer = Mid(MutateString,7);
        PlayerPinged(pingedPlayer);
    }

    //ENDVOTE | if something goes wrong ... end the vote
    if(MutateString == "WTEND"){
        EndVoting();
    }

    //WTRESTART | restart the vote & trim players not logged in
    if(MutateString == "WTTRIM"){
        bAvailableOnly = true;
        LoadPlayerList();
    }

    //WTAUTO | auto assign rest of unpicked players
    if(MutateString == "WTAUTO"){
        failSafeCounter = 0;
        while(getNumberOfUnassignedPlayers() > 0 && failSafeCounter < 40){
            PickPlayer(getUnassignedPlayerIndex(),GetSmallerTeamByVoting());
            failSafeCounter++;
        }

        EndVoting();

    }

    //DEMORECORD | Record Demo
    if(MutateString == "WTDEMOREC"){
        RecordDemo();
    }

    if ( NextMutator != None )
    {
        NextMutator.Mutate(MutateString,Sender);
    }
}

function RecordDemo(){
    local String DateTimeStamp;
    local String MapName;
    local String FileName;
    local Controller C;

    if(!bRecording){
        bRecording = true;
        DateTimeStamp = GetDateTime();
        MapName = GetCurrentMap();
        FileName = ""$ DateTimeStamp $ "-" $ MapName;

        ConsoleCommand("Demorec " $ FileName);


        for( C = Level.ControllerList; C != None; C = C.NextController ){
            if ( C != None ){
                if ( C.IsA('PlayerController') ){
                    PlayerController(C).ClientMessage("Server Recording Started: "$FileName);
                }
            }
        }
    }
}

function string GetDateTime ()
{
  local string AbsoluteTime;

    AbsoluteTime = string(Level.Year);
    if ( Level.Month < 10 )
    {
      AbsoluteTime = AbsoluteTime $ ".0" $ string(Level.Month);
    } else {
      AbsoluteTime = AbsoluteTime $ "." $ string(Level.Month);
    }
    if ( Level.Day < 10 )
    {
      AbsoluteTime = AbsoluteTime $ ".0" $ string(Level.Day);
    } else {
      AbsoluteTime = AbsoluteTime $ "." $ string(Level.Day);
    }
    AbsoluteTime = AbsoluteTime $ "-";

    if ( Level.Hour < 10 )
    {
     AbsoluteTime = AbsoluteTime $ "0" $ string(Level.Hour);
    } else {
     AbsoluteTime = AbsoluteTime $ string(Level.Hour);
    }
    if ( Level.Minute < 10 )
    {
     AbsoluteTime = AbsoluteTime $ ".0" $ string(Level.Minute);
    } else {
     AbsoluteTime = AbsoluteTime $ "." $ string(Level.Minute);
    }

    return AbsoluteTime;
}

function string GetCurrentMap ()
{
  local string MapName;
  local int i;

  MapName = string(Level.Game);
  i = InStr(MapName,".");
  if ( i != -1 ){
    MapName = Left(MapName,i);
  }else{
    MapName = Level.Title;
  }

  return MapName;
}

function PlayerPinged(String PingedPlayer){
    local int wtPlayerIndex;

    wtPlayerIndex = GetPlayerIndexByName(PingedPlayer);
    WTPlayerList[wtPlayerIndex].PlayerMenuOpen=10;

//    if(isLogOn) log("-- WT -- PlayerPinged:"$WTPlayerList[wtPlayerIndex].PlayerName$" Time:"$WTPlayerList[wtPlayerIndex].PlayerMenuOpen);
}

function OpenTeamSelectionPage(){
    local Controller C;
    local bool bUpdateOnly, bOpened;
    local int wtPlayerIndex;

    bUpdateOnly = false;
    bVoteInProcess = True;

    for( C = Level.ControllerList; C != None; C = C.NextController ){
        if (C.PlayerReplicationInfo != none &&  !C.PlayerReplicationInfo.bBot && C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.PlayerName != "WebAdmin"){

            wtPlayerIndex = GetPlayerIndexByName(C.PlayerReplicationInfo.PlayerName);
            WTPlayerList[wtPlayerIndex].PlayerMenuOpen--;

//            if(isLogOn) log("-- WT -- OpenTeamMenu:"$WTPlayerList[wtPlayerIndex].PlayerName$" Time:"$WTPlayerList[wtPlayerIndex].PlayerMenuOpen);
            if(WTPlayerList[wtPlayerIndex].PlayerMenuOpen < 1){
                 bOpened = OpenTeamMenu(PlayerController(C),bUpdateOnly);
                 if(bOpened) WTPlayerList[wtPlayerIndex].PlayerMenuOpen = 10;
            }
        }
    }
}

function bool OpenTeamMenu(PlayerController Sender, bool bUpdateOnly){

    if(Sender == none) return false;
    // This is the call to open the menu
    Sender.ClientOpenMenu("W_TeamVoter.InterfaceTeamVoterPage",bUpdateOnly);
    return true;
}

function CloseTeamSelectionPage(){
    local Controller C;
    local PlayerController P;

    for( C = Level.ControllerList; C != None; C = C.NextController ){
        P = PlayerController(C);
        if ( P != None ){
            if (  !P.PlayerReplicationInfo.bBot ){
                PlayerController(C).ClientCloseMenu(True,false);
            }
        }
    }

}

// ************ Vote GUI - Stop ****************

// ************ Persist - Start ****************

function String LoadPlayersInMenu(){
    return wtStats.GetSerializedData();
}


function SaveScores(){
    local Controller C;

    wtStats.Clear();

    for( C = Level.ControllerList; C != None; C = C.NextController ){
        if(C.PlayerReplicationInfo != none && !C.PlayerReplicationInfo.bBot && C.PlayerReplicationInfo.PlayerName != "WebAdmin" && C.PlayerReplicationInfo.PlayerName != "DemoRecSpectator" ){
            wtStats.AddPlayer(C.PlayerReplicationInfo.PlayerName,C.PlayerReplicationInfo.Score);
        }else{
            if(C.PlayerReplicationInfo != none && isSaveBots && C.PlayerReplicationInfo.PlayerName != "WebAdmin" && C.PlayerReplicationInfo.PlayerName != "DemoRecSpectator"){
                wtStats.AddPlayer(C.PlayerReplicationInfo.PlayerName@"*",999);
            }
        }
    }
    wtStats.SaveSettings();
}

// ************ Persist - Stop ****************

defaultproperties
{
     defaultAutoPick=30
     bAddToServerPackages=True
     GroupName="TeamPicker"
     FriendlyName="W_TeamVoter 8-22-15"
     Description="#Team picking#"
}
