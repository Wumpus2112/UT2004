class TeamSpeak3SynchMut extends Mutator
    config(W_TeamSpeak3Synch);

/* Server-side configurable variables */
var() config int    CheckInterval;      // Number of seconds between player list updates
var() config int    SyncInterval;       // Number of seconds between synchronisations
var() config int    Timeout;        // Number of seconds allowed for synching
var() config bool   MoveSpectators; // Moves spectators to their own channel (AlternateName)
var() config bool   IgnoreOthers;       // Ignore players not in the game channels
var() config bool   NotifyPlayers;      // sends a message to players when they are moved
var() config int    MinNameLength;      // minimum number of characters in players name for it to be 'recognised'
var() config int    MinBeforeSwitch;
var() config bool   isDebug;

/* TS server details */
var() config string     TSServerIP;
var() config int        TSServerPort;
var() config int        TSServerSuperPort;
var() config string     LoginType;
var() config string     LoginName;
var() config string     ServerPassword;
var() config string     ChannelPassword;

/* Channel/player details */
struct ChannelInfo
{
    var string ChannelId;
    var string ChannelName;
};
var ChannelInfo Channels[4];

var() config string     ChannelName[4]; // Names of the corresponding TS channels
var() config string     AlternateName;  // Name of the channel for anyone else (e.g. 255=spectator)


/* local varables */
var() name LogClassName;
var() bool isInit;

/* Internal vars */
var int             Time;
var Teamspeak3LinkChannel  channelLink;
var Teamspeak3LinkPlayer   playerLink;
var bool isWaitingforPlayerRefresh;

var bool    Busy;

var bool isChannelInitialized;

var int NumberOfCurrentPlayers;
var int NumberOfSynchedPlayers;

auto State MatchInProgress
{
    function Timer()
    {
        if (isDebug) Log ("Timer", LogClassName);

        if(!isChannelInitialized){
            if(!channelLink.isBusy){
                if (isDebug) Log ("Timer: Initializing Channels", LogClassName);
                InitializeChannels();
                isChannelInitialized = true;
            }
        }else{

            if(Level.Game.bTeamGame){
                CheckSynch();
            }else{
                if (isDebug) Log ("Timer: Not Team Game turning off timer.", LogClassName);
                DefaultChannelPlayers();
                SetTimer(0.0, false);
            }
        }

        if(isWaitingforPlayerRefresh){
           RefreshPlayers();
        }


        // Check for match end
        if (Level.Game.bGameEnded)
        {
            if (isDebug) Log ("Timer:GameEnded", LogClassName);
            DefaultChannelPlayers();
            SetTimer(0.0, false);
        }
    }

}

state MatchEnded
{
Begin:
    if (isDebug) Log ("MatchEnded: Move to Default", LogClassName);
    DefaultChannelPlayers();
    SetTimer(0.0, false);
}

/* initialise the connection(s) and timer
*/
function PostBeginPlay()
{
    if (isDebug) Log ("PostBeginPlay: Initializing Team and Player Connections.", LogClassName);
    channelLink = Spawn (class'Teamspeak3LinkChannel',self,,,);
    channelLink.isDebug = isDebug;
    channelLink.Initialise (TSServerIP, TSServerPort, TSServerSuperPort, LoginType, LoginName, ServerPassword, isDebug);

    playerLink = Spawn (class'Teamspeak3LinkPlayer',self,,,);
    playerLink.isDebug = isDebug;
    playerLink.Initialise (TSServerIP, TSServerPort, TSServerSuperPort, LoginType, LoginName, ServerPassword, isDebug);

    SetTimer(3.0, true);
    Time = 0;
}

function InitializeChannels(){
    local int i;

    for(i=0;i < 4;i++){
        Channels[i].ChannelName = ChannelName[i];
        Channels[i].ChannelId = channelLink.GetChannelIdByName(ChannelName[i]);
        if (isDebug) Log ("InitializeChannels: Number["$i$"] Name["$Channels[i].ChannelName$"] ID["$Channels[i].ChannelId$"]", LogClassName);
    }
    channelLink.CloseConnection();
}


/* check if players need syncing
*/
function CheckSynch()
{
    Time++;
    if (isDebug) Log ("CheckSynch: Time["$string(Time)$"]", LogClassName);

    if (Time%SyncInterval == 0)
    {
        SynchPlayers();
        isWaitingforPlayerRefresh = true;
    }

    if(Time%CheckInterval == 0){
         playerLink.ExecuteQuery();
    }

}

function ModifyLogin (out string Portal, out string Options){
    super.ModifyLogin(Portal,Options);
    RefreshPlayers();
}

function RefreshPlayers(){
    if (isDebug) Log ("RefreshPlayers: Begin", LogClassName);

    if (playerLink.isBusy == false)
    {
        if (isDebug) Log ("RefreshPlayers: Executing Query", LogClassName);
        playerLink.ExecuteQuery();
        isWaitingforPlayerRefresh = false;
    }else{
        if (isDebug) Log ("RefreshPlayers: Busy. Try again later.", LogClassName);
    }
}


/* Synchronise the players in the TS server with the gameserver
*/
function SynchPlayers()
{
    local Pawn P;
    local Controller C;
    local string PlayerName;
    local int PlayerTeam;
    local int count;

    local string PlayerChannelId, PlayerChannelIdTarget,PlayerClientId;

    if (isDebug) Log ("SynchPlayers: Begin", LogClassName);

    // count players to see if exceeds min threshold
    count =0;
    for (C = Level.ControllerList; C != None; C = C.nextController)
    {
        if (isPlayer(C.Pawn)) count++;
    }
    if(count < MinBeforeSwitch){
        if (isDebug) Log ("SynchPlayers: Not Moving Players - Minimum Required["$MinBeforeSwitch$"] Current["$count$"]", LogClassName);
        return;
    }


    if (isDebug) Log ("SynchPlayers: Move Players", LogClassName);
    // min threshold exceeded, move players
    for (C = Level.ControllerList; C != None; C = C.nextController)
    {
        P = C.Pawn;

        if (isPlayer(P)){

            PlayerName = P.PlayerReplicationInfo.PlayerName;
            PlayerTeam = P.PlayerReplicationInfo.Team.TeamIndex+1;
            PlayerChannelId= playerLink.GetChannelIdByPlayerName(PlayerName);
            PlayerClientId = playerLink.GetClientIdByPlayerName(PlayerName);

            if (PlayerClientId == "-1")
            {
                if (isDebug) Log ("SynchPlayers: "$PlayerName $ " not found on server, ignoring.", LogClassName);
                continue;
            }

            if (PlayerChannelId == "-1")
            {
                if (isDebug) Log ("SynchPlayers: "$PlayerName$ "ERROR: Invalid Channel number" , LogClassName);
                continue;
            }

            PlayerChannelIdTarget = Channels[PlayerTeam].ChannelId;

            if (PlayerChannelIdTarget != PlayerChannelId)
            {
                if (isDebug) Log ("SynchPlayers: Moving " $ PlayerName $ " to channel " $ PlayerChannelIdTarget, LogClassName);

                if (NotifyPlayers) P.ClientMessage ("You are being moved to TeamSpeak channel '" $ PlayerChannelIdTarget $ "'");

                playerLink.MovePlayer(PlayerClientId,PlayerChannelIdTarget,ChannelPassword);

            }else{
                if (isDebug) Log ("SynchPlayers: "$PlayerName$ " Not moving. Already in channel." , LogClassName);
            }
        }else{
             if (isDebug) Log ("SynchPlayers: Not a player", LogClassName);
        }
    }
    if (isDebug) Log ("SynchPlayers: Synch complete.", LogClassName);
}

function bool isPlayer(Pawn p){
    return (P != None
        && P.PlayerReplicationInfo != None
        && P.PlayerReplicationInfo.PlayerName != "Player"
        && P.PlayerReplicationInfo.Team !=None
        && !P.PlayerReplicationInfo.bBot);
}


/* Synchronise the players in the TS server with the gameserver
*/
function DefaultChannelPlayers()
{
    if (isDebug) Log ("DefaultChannelPlayers: Start", LogClassName);

    playerLink.MoveAllPlayers(Channels[0].ChannelId,ChannelPassword);

    if (isDebug) Log ("DefaultChannelPlayers: Complete.", LogClassName);
}

/* Thanks to the Unreal Wiki for this one
*/
static function string LowerCase (coerce string Text)
{
    local int IndexChar;

    for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
    {
        if (Mid(Text, IndexChar, 1) >= "A"
         && Mid(Text, IndexChar, 1) <= "Z")
        {
            Text = Left(Text, IndexChar) $ Chr(Asc(Mid(Text, IndexChar, 1)) + 32) $ Mid(Text, IndexChar + 1);
        }
    }

    return Text;
}

event Destroyed()
{

    channelLink.Destroy();
    playerLink.Destroy();
}

defaultproperties
{
     CheckInterval=15
     SyncInterval=5
     TimeOut=3
     IgnoreOthers=True
     MinNameLength=3
     TSServerIP="chi2.voicemonsters.com"
     TSServerPort=10028
     TSServerSuperPort=10011
     LoginType="Admin"
     LoginName="Wumpus"
     ServerPassword="wgAviknV"
     ChannelPassword="wumpus"
     ChannelName(0)="DefaultsChannel"
     ChannelName(1)="Red"
     ChannelName(2)="Blue"
     ChannelName(3)="Team D"
     AlternateName="Spectators"
     LogClassName="TeamSpeak3SynchMut"
     GroupName="TeamSpeak3 Group"
     FriendlyName="Teamspeak3 Synch 4-22-16"
     Description="Moves players to the appropriate TeamSpeak3 Channels"
     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
