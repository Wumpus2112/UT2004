class TS3ChannelLink extends TcpLink;

var() name LogClassName;
var() int  ConversationAttach, ConversationState, ConversationServerSelect, ConversationLogin, ConversationQuery, ConversationAdHoc;
var() bool isDebug;
var() bool isTrace;

var bool   isSuccessful;

var string  ServerAddress;      // Address of the server to connect
var int     ServerPort;
var int     RemotePort;         // Port of the server to connect
var string  ClientName;
var string  ClientPassword;
var string  ChannelPassword;

var string  LF, tab;        // Line feed character
var string  buf;            // Recieve buffer (for when the recievedtext goes over 999 characters)

/*************************************/

struct TSChannelInfo
{
    var string ChannelId;
    var string ChannelName;
};

var array<TSChannelInfo> TSChannelInfolList;

var string redChannelId;
var string blueChannelId;
var string defaultChannelId;

/*************************************/

struct TSPlayerInfo
{
    var string ClientChannelId, ClientId, PlayerName, ChannelName;
    var bool   isRedChannel,isBlueChannel,isRedTeam,isBlueTeam,isBalanced;
};
var array<TSPlayerInfo> TSPlayerInfoList;

var string DefaultPassword;

var string InProcessQueryResult;

var bool   isMatchInProgress;
var bool   channelsInitialized;
var int channelQueryConsecutiveCounter;


/*************************************/

var bool isPlayerQuery;

/*************************************/
/*  Public methods                   */

function synchPlayersAndChannels(){
    local bool isUpdated;

    if(isMatchInProgress){
        if (isDebug) Log ("synchPlayersAndChannels", LogClassName);
        setPlayerGameTeams();
    }

    if (isDebug) Log ("channelQueryConsecutiveCounter:"@channelQueryConsecutiveCounter, LogClassName);
    if(channelQueryConsecutiveCounter< 1){
        isUpdated = false;
        isUpdated = synchPlayers();
        if(!isUpdated){
            channelQueryConsecutiveCounter = 6;
        }
    }else{
        channelQueryConsecutiveCounter = channelQueryConsecutiveCounter - 1;
    }
}

function matchStarted(){
    isMatchInProgress = true;
    channelsInitialized = false;
    //initializeChannels();
    channelQueryConsecutiveCounter = 0;
}

function matchEnded(){
    local int i;

    isMatchInProgress=false;
    channelQueryConsecutiveCounter=0;
    for(i=0;i<TSPlayerInfoList.length;i++){
        TSPlayerInfoList[i].isRedTeam = false;
        TSPlayerInfoList[i].isBlueTeam = false;
        TSPlayerInfoList[i].isBalanced = false;
    }

    synchPlayersAndChannels();
}

/*************************************/
/* Utils                             */

function int getPlayerIndexByName(String PlayerName){
    local int i;

    for(i=0;i<TSPlayerInfoList.length;i++){
        if(PlayerName == TSPlayerInfoList[i].PlayerName) return i;
    }

    return -1;
}


function bool isPlayer(Pawn p){
    return (P != None
        && P.PlayerReplicationInfo != None
        && P.PlayerReplicationInfo.PlayerName != "Player"
        && P.PlayerReplicationInfo.Team !=None
        && !P.PlayerReplicationInfo.bBot);
}

/*************************************/

function setPlayerGameTeams(){
    local Pawn P;
    local Controller C;
    local string PlayerName;
    local int pIndex;
    local int playerTeamNum;

    if (isDebug) Log ("setPlayerGameTeams", LogClassName);

    for (C = Level.ControllerList; C != None; C = C.nextController)
    {
        P = C.Pawn;
        if (isPlayer(P)){
            PlayerName = P.PlayerReplicationInfo.PlayerName;
            pIndex = getPlayerindexByName(PlayerName);
            if(pIndex>-1){
                playerTeamNum = P.PlayerReplicationInfo.Team.TeamIndex;

                TSPlayerInfoList[pIndex].isRedTeam = (playerTeamNum == 0);
                TSPlayerInfoList[pIndex].isBlueTeam = (playerTeamNum == 1);
            }
        }
    }

}

function loadChannels(){
    if (isDebug) Log ("setPlayerChannels", LogClassName);

    isPlayerQuery=false;
    ConversationState=ConversationQuery;
    SendRequest();
}

function getPlayerChannels(){
    if (isDebug) Log ("getPlayerChannels", LogClassName);

    isPlayerQuery=true;
    ConversationState=ConversationQuery;
    SendRequest();
}

function bool synchPlayers(){
    local int i;
    isPlayerQuery=true;

    if (isDebug) Log ("synchPlayers", LogClassName);

    if(!Level.Game.bTeamGame) return true;

    if(!initializeChannels()) return true;

    for(i=0;i< TSPlayerInfoList.length;i++){

        if (isDebug){
            Log ("Player:"@TSPlayerInfoList[i].PlayerName@" - RedChannel:"@TSPlayerInfoList[i].isRedChannel@" - RedTeam:"@TSPlayerInfoList[i].isRedTeam@" - BlueChannel:"@TSPlayerInfoList[i].isBlueChannel@" - BlueTeam:"@TSPlayerInfoList[i].isBlueTeam, LogClassName);
        }

        if(TSPlayerInfoList[i].isRedTeam && !TSPlayerInfoList[i].isRedChannel){
            if (isDebug) Log ("MovePlayer:"@TSPlayerInfoList[i].PlayerName@" - to Red", LogClassName);
            if(TSPlayerInfoList[i].isBalanced) return true;
            MovePlayer(TSPlayerInfoList[i].ClientId, redChannelId, ChannelPassword);
            TSPlayerInfoList[i].isRedChannel = true;
            TSPlayerInfoList[i].isBalanced = true;
            return true;
        }

        if(TSPlayerInfoList[i].isBlueTeam && !TSPlayerInfoList[i].isBlueChannel){
            if (isDebug) Log ("MovePlayer:"@TSPlayerInfoList[i].PlayerName@" - to Blue", LogClassName);
            if(TSPlayerInfoList[i].isBalanced) return true;
            MovePlayer(TSPlayerInfoList[i].ClientId, blueChannelId, ChannelPassword);
            TSPlayerInfoList[i].isBlueChannel = true;
            TSPlayerInfoList[i].isBalanced = true;
            return true;
        }

        if(!TSPlayerInfoList[i].isBlueTeam && !TSPlayerInfoList[i].isRedTeam){
            if(TSPlayerInfoList[i].isRedChannel || TSPlayerInfoList[i].isBlueChannel){
                if(TSPlayerInfoList[i].ClientChannelId != defaultChannelId){
                    if (isDebug) Log ("MovePlayer:"@TSPlayerInfoList[i].PlayerName@" - to Default", LogClassName);
                    if(TSPlayerInfoList[i].isBalanced) return true;
                    MovePlayer(TSPlayerInfoList[i].ClientId, defaultChannelId, ChannelPassword);
                    TSPlayerInfoList[i].ClientChannelId = defaultChannelId;
                    TSPlayerInfoList[i].isBalanced = true;
                    return true;
                }
            }
        }

    }

    //getPlayerChannels();
    return false;
}

function bool initializeChannels(){
// failsafe
    if(channelsInitialized) return true;
    if(Len(redChannelId) == 0 || Len(blueChannelId) == 0 || Len(defaultChannelId) == 0){
        Log ("initializeChannels NOT INITIALIZED !", LogClassName);
        loadChannels();
        return true;
    }else{
        channelsInitialized = true;
        if (isDebug) Log ("initializeChannels - initialized", LogClassName);
        return true;
    }
}

function string GetChannelQueryString(){
    return "channellist";
}

function string GetPlayerQueryString(){
    return "clientlist";
}



function SendRequest(){

    local string query;

    switch(ConversationState){
        case ConversationServerSelect:
            if (isDebug) Log ("SendRequest-ConversationServerSelect: Begin", LogClassName);
            SendText("use port=" $ ServerPort);
            break;
        case ConversationLogin:
            if (isDebug) Log ("SendRequest-ConversationLogin: Begin", LogClassName);
            SendText("login " $ ClientName $ " " $ ClientPassword);
            break;
        case ConversationQuery:
            if (isDebug) Log ("SendRequest-ConversationQuery: Begin", LogClassName);
            if(isPlayerQuery){
                if (isDebug) Log ("SendRequest-GetPlayerQuery: Begin", LogClassName);
                query = GetPlayerQueryString();
            }else{
                if (isDebug) Log ("SendRequest-GetChannelQuery: Begin", LogClassName);
                query = GetChannelQueryString();
            }
            SendText(query);
            break;
        default:
            if (isDebug) Log ("SendRequest-default: Error unknown ConversationState", LogClassName);
    }
}

function ProcessResponse(string Text){
    log("ProcessResponse: ["$Text$"]");

    switch(ConversationState){

        case ConversationAttach:
            if (isDebug) Log ("ProcessResponse-ConversationAttach: Begin", LogClassName);
            ConversationState=ConversationServerSelect;
            SendRequest();
            break;
        case ConversationServerSelect:
            if (isDebug) Log ("ProcessResponse-ConversationServerSelect: Begin", LogClassName);
            ConversationState=ConversationLogin;
            SendRequest();
            break;
        case ConversationLogin:
            if (isDebug) Log ("ProcessResponse-ConversationLogin: Begin", LogClassName);
            ConversationState=ConversationQuery;

            loadChannels();

            break;

        case ConversationQuery:
            if (isDebug) Log ("ProcessResponse-ConversationQuery: Begin", LogClassName);
            isSuccessful = ProcessQueryResult(Text);
            if(!isSuccessful) ResetConversation();
            break;
        case ConversationAdHoc:
            if (isDebug) Log ("ProcessResponse-ConversationAdHoc: Begin", LogClassName);
            ProcessPlayerAdHocResult(Text);
        default:
            Log ("ProcessResponse-default: Error unknown ConversationState. Message Received: "$Text, LogClassName);
    }
}

function ResetConversation(){
    CloseConnection();
    StartConnection();
    ConversationState = ConversationAttach;
}

function bool ProcessQueryResult(string Text){


    if(Right(Text,2) == "ok") return true;

    if(isPlayerQuery){
        ProcessPlayerQueryResult(Text);
    }else{
        ProcessChannelQueryResult(Text);
    }
    return true;
}

function bool ProcessChannelQueryResult(string Text){
    local array<string> ChannelText,ChannelProperty,PropertyValuePairs;
    local int i,j;
    local int ChannelTextSize,ChannelPropertySize,PropertyValuePairSize;
    local string PropertyName, PropertyValue;

    local string ChannelId,ChannelName;

    if (isDebug) Log ("ProcessChannelQueryResult: " $ Text, LogClassName);

    TSChannelInfolList.Remove(0,TSChannelInfolList.Length);

    ChannelTextSize=Split(Text,"|",ChannelText);

    if (isDebug) Log("ProcessQueryResult: NumberOf Channels: " $string(ChannelText.Length));
    if(ChannelText.Length < 2){
        Log("ProcessQueryResult: ERROR! NumberOf Channels: " $string(ChannelText.Length));
        //return false;
    }

    for(i=0 ; i < ChannelTextSize ; i++)
	{
	    if (isDebug) Log ("ChannelText [" $ChannelText[i]$ "]", LogClassName);

		ChannelPropertySize=Split(ChannelText[i]," ",ChannelProperty);
        for(j=0;j<ChannelPropertySize;j++)
	    {
	        if (isTrace) Log ("ChannelProperty [" $ChannelProperty[j]$ "]", LogClassName);

            PropertyValuePairSize=Split(ChannelProperty[j],"=",PropertyValuePairs);

            if(PropertyValuePairs.Length>1){
                PropertyName=PropertyValuePairs[0];
                PropertyValue=PropertyValuePairs[1];
            }

		    if(PropertyName == "cid"){
		        ChannelId = PropertyValue;
                if (isDebug) Log ("ChannelId: " $ ChannelId, LogClassName);
		    }

		    if(PropertyName == "channel_name"){
		        ChannelName = PropertyValue;
                if (isDebug) Log ("ChannelName: " $ ChannelName, LogClassName);
		    }

		}

        AddTSChannelInfo(ChannelId, ChannelName);
	}

    getPlayerChannels();

	return true;
}


/******************************/

function bool ExecuteQuery(){
    ConversationState=ConversationQuery;
    SendRequest();
    return true;
}

function bool ProcessPlayerQueryResult(string Text){
    local array<string> PlayerLines,PlayerProperties,PropertyValuePairs;
    local int i,j;
    local int PlayerTextSize,PlayerPropertySize,PropertyValuePairSize;
    local string PropertyName, PropertyValue;
    local string TextEnding;

    local string PlayerName, ClientId, ChannelId;
    local bool isAdmin;


    if (isDebug) Log ("ProcessPlayerQueryResult: " $ Text, LogClassName);
               // build a new list ...
    isAdmin=false;

    // build a new list ...
    TSPlayerInfoList.Remove(0,TSPlayerInfoList.Length);

    TextEnding = Right(Text,13);
    if(TextEnding == "client_type=1" || TextEnding == "client_type=0"){
        // process
        Text = InProcessQueryResult$Text;
        InProcessQueryResult = "";
    }else{
        InProcessQueryResult = InProcessQueryResult$Text;
//        ConversationState = ConversationQuery
        return true;
    }

    PlayerTextSize=Split(Text,"|",PlayerLines);

    if (isDebug) Log("ProcessQueryResult: NumberOf Players: " $string(PlayerLines.Length));

    if(PlayerLines.Length == 0){
        Log("ProcessQueryResult: ERROR! NumberOf Players: " $string(PlayerLines.Length));
        return false;
    }

    for(i=0;i<PlayerTextSize;i++)
	{
	    if (isDebug) Log ("PlayerLines [" $PlayerLines[i]$ "]", LogClassName);

		PlayerPropertySize=Split(PlayerLines[i]," ",PlayerProperties);

        if(PlayerProperties.Length == 0){
            Log("ProcessQueryResult: ERROR! NumberOf PlayerProperties: " $string(PlayerProperties.Length));
            return false;
        }

        for(j=0;j<PlayerPropertySize;j++)
	    {
	        if (isTrace) Log ("PlayerProperties [" $PlayerProperties[j]$ "]", LogClassName);

            PropertyValuePairSize=Split(PlayerProperties[j],"=",PropertyValuePairs);

            if(PropertyValuePairs.Length>1){
                PropertyName=PropertyValuePairs[0];
                PropertyValue=PropertyValuePairs[1];
            }

		    if(PropertyName == "clid"){
		        ClientId = PropertyValue;
                if (isDebug) Log ("CLID/ClientId: " $ ClientId, LogClassName);
		    }
		    if(PropertyName == "cid"){
		        ChannelId = PropertyValue;
                if (isDebug) Log ("CID/ClientChannelId: " $ ChannelId, LogClassName);
		    }

		    if(PropertyName == "client_type"){
		        isAdmin = (PropertyValue == "1");
		        if (isDebug) Log ("client_type/isAdmin: " $ isAdmin, LogClassName);
		    }

		    if(PropertyName == "client_nickname"){
		        PlayerName = ParsePlayerName(PropertyValue);
		        if (isDebug) Log ("client_nickname/PlayerName: " $ PlayerName, LogClassName);
		    }


		}

        if(!isAdmin) AddPlayerInfo(PlayerName, ClientId, ChannelId);

	}

	return true;

}

function AddPlayerInfo(string PlayerName, string ClientId, string channelId){
     local int playerIndex;

     playerIndex = getPlayerindexByName(PlayerName);

     if(playerIndex < 0){
         playerIndex = TSPlayerInfoList.Length;
         TSPlayerInfoList.Insert(playerIndex,1);
         TSPlayerInfoList[playerIndex].PlayerName = PlayerName;

         TSPlayerInfoList[playerIndex].isRedTeam=false;
         TSPlayerInfoList[playerIndex].isBlueTeam=false;
         TSPlayerInfoList[playerIndex].isBalanced = false;
         TSPlayerInfoList[playerIndex].ClientId = ClientId;
         TSPlayerInfoList[playerIndex].isRedChannel = (redChannelId == channelId);
         TSPlayerInfoList[playerIndex].isBlueChannel  = (blueChannelId == channelId);
     }
}

function AddTSChannelInfo(string channelId, string channelName){
     local int channelIndex;

     channelIndex = TSChannelInfolList.Length;
     TSChannelInfolList.Insert(channelIndex,1);
     TSChannelInfolList[channelIndex].ChannelId = channelId;
     TSChannelInfolList[channelIndex].ChannelName = channelName;

     if(channelIndex == 0) defaultChannelId = channelId;
     if(channelName == "Red") redChannelId = channelId;
     if(channelName == "Blue") blueChannelId = channelId;
}



function string ParsePlayerName(string NameToFormat){
    local string FormattedName;
    local array<string> FormattedNames;
    local int FormattedNameLength;

    FormattedName = "";

    FormattedNameLength = Split(NameToFormat,"\\",FormattedNames);

    FormattedName = FormattedNames[0];

    return FormattedName;
}

function MovePlayer(string ClientId, string ClientChannelId, string password  ){
    ConversationState = ConversationAdHoc;

    if (isDebug) Log ("MovePlayer", LogClassName);

    SendText("clientmove clid="$ClientId$" cid="$ClientChannelId$" cpw="$password);
    return;

}

function ProcessPlayerAdHocResult(string Text){
    if (isDebug) Log ("ProcessPlayerAdHocResult"@Text, LogClassName);
    synchPlayers();
}

/******************************/
/*                            */
/* Protocol Code - Begin      */
/*                            */
/******************************/




function Initialise(string IP, int Port, int SuperPort, string type, string login, string passwordServer, string passwordChannel, optional bool debug)
{
    if (isDebug) Log ("- Initialise -", LogClassName);

    ServerAddress = IP;
    ServerPort = Port;
    RemotePort = SuperPort;
    ClientName = login;
    ClientPassword = passwordServer;
    ChannelPassword = passwordChannel;

    isDebug = debug;

    LF = Chr(10); // Line feed char "\n"
    tab = Chr(9);

    isSuccessful = false;
    StartConnection();
}

// First function called (init of the TCP connection)
function StartConnection(){
    buf = "";

    if (isDebug) Log ("StartConnection: Attempt to 'Resolve' Server Address", LogClassName);
    Resolve (ServerAddress);   // Resolve the address of the server
}

event Resolved(IpAddr Addr ){
    if (isDebug) Log ("Resolved: Attempt to 'Connect' to Server", LogClassName);
    Connect(Addr);
}

// If the IP was not resolved...
event ResolveFailed()
{
    if (isDebug) Log ("ResolveFailed: ERROR - Unable to 'Resolve' Server Address. Will not attempt server connection.", LogClassName);
}

// called from resolve event
function Connect(IpAddr Addr){

    Addr.Port = RemotePort;
    BindPort(); // In UnrealTournament, the CLIENT has to make a bind to create a socket! (Not as a classic TCP connection!!!)

    ReceiveMode = RMODE_Event;  // Incomming messages are triggering events, not using Manual Mode
    LinkMode = MODE_Text;       // We expect to receive texts (if we receive data)

    if (isDebug) Log ("Connect: Attempt to  'Open' a server connection.", LogClassName);
    Open(Addr);                 // Open the connection
    if (isDebug) Log ("Connect: Connected ["$Addr.Addr$":"$Addr.port$"]", LogClassName);
}



function bool CloseConnection(){
    if (isDebug) Log ("CloseConnection: Attempt to 'Close' Connection", LogClassName);
    return Close();
}

//-----------------------------------------------------------------------------
// natives.

// SendText: Sends text string.
// Appends a cr/lf if LinkMode=MODE_Line.  Returns number of bytes sent.
//native function int SendText( coerce string Str );
function int SendText (coerce string Str)
{
    local int result;

    log("SendText: ["$Str$"]");

    result = Super.SendText (Str$LF);  // Call the super (send the text)
    if(isDebug) Log ("SendText: ["$Str$"] length: "$result, LogClassName);

    return result;
}

// ReadText: Reads text string.
// Returns number of bytes read.
//native function int ReadText( out string Str );
function int ReadText (out string Str)
{
    local int result;

    result = Super.ReadText (Str);  // Call the super (read the text)
    if(isDebug) Log ("ReceivedLine: ["$Str$"] - ERROR Unexpected Method call. Using events for reading text. Change receive mode. See 'InternetInfo' class", LogClassName);

    return result;
}

//-----------------------------------------------------------------------------
// Events.

// Accepted: Called during STATE_Listening when a new connection is accepted.
event Accepted(){
      if(isDebug) Log ("Accepted", LogClassName);
}


// Opened: Called when socket successfully connects.
event Opened(){
    if(isDebug) Log ("Opened", LogClassName);
}

// Closed: Called when Close() completes or the connection is dropped.
event Closed(){
    if(isDebug) Log ("Closed", LogClassName);
}

// ReceivedText: Called when data is received and connection mode is MODE_Text.
event ReceivedText( string Text ){
     //if(isTrace) Log ("ReceivedText: ["$Text$"]", LogClassName);
     Text = TrimText(Text);
     if(isTrace) Log ("ReceivedText-Trim: ["$Text$"]", LogClassName);

//     if(Text == "error id=1024 msg=invalid\sserverID"){
//         ResetConversation();
//         return;
//     }


     ProcessResponse(Text);
}

function string TrimText(string Text){
    local int lineFeedIndex;
    lineFeedIndex = InStr(Text, LF);
    if(lineFeedIndex<0){
        return Text;
    }
    return Left(Text,lineFeedIndex);
}


// ReceivedLine: Called when data is received and connection mode is MODE_Line.
// \r\n is stripped from the line
event ReceivedLine( string Line ){
      if(isDebug) Log ("ReceivedLine: ["$Line$"] - ERROR Unexpected Receive line. Change 'LinkMode' to 'MODE_Text'.", LogClassName);
}

/******************************/
/*                            */
/* Protocol Code - End      */
/*                            */
/******************************/



defaultproperties
{
     isDebug=false;
     isTrace=false;

     LogClassName="TS3ChannelLink"
     ConversationServerSelect=1
     ConversationLogin=2
     ConversationQuery=3
     ConversationAdHoc=4
}
