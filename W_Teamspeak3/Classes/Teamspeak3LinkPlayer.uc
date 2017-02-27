class Teamspeak3LinkPlayer extends Teamspeak3Link;

struct PlayerInfo
{
    var string ClientChannelId, ClientId, PlayerName;
    var bool   isAdmin;
};
var PlayerInfo Players[50];
var int          NumPlayers;
var int MoveAllPlayersCounter;
var string DefaultClientChannelId;
var string DefaultPassword;

var string InProcessQueryResult;

function string GetChannelIdByPlayerName (String PlayerName)
{
    local int i;
    for(i=0;i<NumPlayers;i++){
        if(PlayerName == Players[i].PlayerName && !Players[i].isAdmin) return Players[i].ClientChannelId;
    }
    return "-1";
}

function string GetClientIdByPlayerName (String PlayerName)
{
    local int i;
    for(i=0;i<NumPlayers;i++){
        if (isTrace) Log ("GetClientIdByPlayerName: GameName["$PlayerName$"] TSName["$Players[i].PlayerName$"]", LogClassName);
        if(PlayerName == Players[i].PlayerName && !Players[i].isAdmin) return Players[i].ClientId;
    }
    return "-1";
}

function bool ExecuteQuery(){
    ConversationState=ConversationQuery;
    super.SendRequest();
    return true;
}

function bool ProcessQueryResult(string Text){
    local array<string> PlayerLines,PlayerProperties,PropertyValuePairs;
    local int i,j;
    local int PlayerTextSize,PlayerPropertySize,PropertyValuePairSize;
    local string PropertyName, PropertyValue;
    local string TextEnding;

    if (isDebug) Log ("ProcessQueryResult: " $ Text, LogClassName);

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

    NumPlayers = 0;
    for(i=0;i<PlayerTextSize;i++)
	{
        NumPlayers++;
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
		        Players[i].ClientId = PropertyValue;
                if (isDebug) Log ("CLID/ClientId: " $ Players[i].ClientId, LogClassName);
		    }
		    if(PropertyName == "cid"){
		        Players[i].ClientChannelId = PropertyValue;
                if (isDebug) Log ("CID/ClientChannelId: " $ Players[i].ClientChannelId, LogClassName);
		    }

		    if(PropertyName == "client_type"){
		        Players[i].isAdmin = (PropertyValue == "1");
		        if (isDebug) Log ("client_type/isAdmin: " $ Players[i].isAdmin, LogClassName);
		    }

		    if(PropertyName == "client_nickname"){
		        Players[i].PlayerName = ParsePlayerName(PropertyValue);
		        if (isDebug) Log ("client_nickname/PlayerName: " $ Players[i].PlayerName, LogClassName);
		    }

		}

	}

	return true;

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


function string GetQueryString(){
    return "clientlist";
}

function MovePlayer(string ClientId, string ClientChannelId, string password  ){
    isBusy = true;
    ConversationState = ConversationAdHoc;
    MoveAllPlayersCounter = -1;

    SendText("clientmove clid="$ClientId$" cid="$ClientChannelId$" cpw="$password);
    return;

}

function MoveAllPlayers(string ClientChannelId, string password  ){
    isBusy = true;
    ConversationState = ConversationAdHoc;
    DefaultPassword=password;
    MoveAllPlayersCounter = 0;
    while(Players[MoveAllPlayersCounter].isAdmin){
        MoveAllPlayersCounter++;
    }

    DefaultClientChannelId = ClientChannelId;
    Players[MoveAllPlayersCounter].ClientChannelId = ClientChannelId; // change array to target channel
    SendText("clientmove clid="$Players[MoveAllPlayersCounter].ClientId$" cid="$ClientChannelId$" cpw="$DefaultPassword);
    return;
}

function bool ProcessAdHocResult(string Text){
    if(MoveAllPlayersCounter == -1){
        isBusy = false;
        return true;
    }

    MoveAllPlayersCounter++;

    while(Players[MoveAllPlayersCounter].isAdmin){
        MoveAllPlayersCounter++;
    }

    if(MoveAllPlayersCounter < NumPlayers){
        Players[MoveAllPlayersCounter].ClientChannelId = DefaultClientChannelId; // change array to target channel
        SendText("clientmove clid="$Players[MoveAllPlayersCounter].ClientId$" cid="$DefaultClientChannelId$" cpw="$DefaultPassword);
    }else{
        isBusy = false;
    }
    return true;
}

defaultproperties
{
     LogClassName="Teamspeak3LinkPlayer"
}
