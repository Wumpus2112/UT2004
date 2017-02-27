class TS3ChannelMut extends Mutator config(TS3ChannelSynch);

/* Server-side configurable variables */
var() config int    SyncInterval;       // Number of seconds between synchronisations
var() config bool   NotifyPlayers;      // sends a message to players when they are moved
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


/* local varables */
var name LogClassName;

/* Internal vars */
var TS3ChannelLink  tsLink;


function PostBeginPlay()
{
    if (isDebug) Log ("PostBeginPlay: Initializing Team and Player Connections.", LogClassName);
    tsLink = Spawn (class'TS3ChannelLink',self,,,);
    tsLink.isDebug = isDebug;
    tsLink.Initialise (TSServerIP, TSServerPort, TSServerSuperPort, LoginType, LoginName, ServerPassword, ChannelPassword, isDebug);
}


auto State MatchInProgress
{
    function Timer(){
        if (isDebug) Log ("Timer fired", LogClassName);
        tsLink.synchPlayersAndChannels();
    }


Begin:
    tsLink.matchStarted();
    if(Level.Game.bTeamGame){
        SetTimer(SyncInterval, true);
    }

}

state MatchEnded
{
Begin:
    if (isDebug) Log ("MatchEnded: Move to Default", LogClassName);
    tsLink.matchEnded();
}


event Destroyed()
{
    tsLink.Destroy();
}

defaultproperties
{
     SyncInterval=5
     isDebug=false
     TSServerIP="CHI2.TheGameMonsters.com"
     TSServerPort=10028
     TSServerSuperPort=10011
     LoginType="Admin"
     LoginName="Wumpus"
     ServerPassword="wgAviknV"
     ChannelPassword="wumpus"
     LogClassName="TS3ChannelSynchMut"
     GroupName="TS3Channel Group"
     FriendlyName="TS3Channel 4-23-16"
     Description="Moves players to the appropriate TS3Channel Channels"
     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
