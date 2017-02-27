//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutSounds extends Mutator
     config (W_Sounds);

#exec OBJ LOAD FILE="..\Sounds\GlitchModSounds.uax"
#exec OBJ LOAD FILE="..\Sounds\Banyan.uax"

struct ThemeData
{
    var string PlayerName;
    var() sound SoundName;
};
var protected config array<ThemeData> ThemeList;

struct TriggerData
{
    var string TriggerName;
    var() sound SoundName;
};
var protected config array<TriggerData> TriggerList;

struct QueueData
{
    var string PlayerName;
    var() sound SoundName;
};

var protected array<QueueData> QueueList;

var protected array<string> QueuePlayerNames;

var bool bInProgress;

event Timer(){
    PlayQueue();
}

function string ParseChatPercVar(Controller Who, string Cmd)
{
    Log("W_Sound: ParseChatPercVar["@Cmd@"]");

	if (NextMutator !=None)
		Cmd = NextMutator.ParseChatPercVar(Who,Cmd);

	return Cmd;
}

function PlaySoundName(sound SoundName, PlayerController c){
    c.PlayAnnouncement(SoundName, 1, true);
}

function PlayTheme(String PlayerName){
    local PlayerController c;
    local sound PlayerSound;

    PlayerSound = GetPlayerTheme(PlayerName);

    foreach DynamicActors(class'PlayerController', c){
        PlaySoundName(PlayerSound, c);
    }
}

function sound GetPlayerTheme(String PlayerName){
    local int i;

    for(i=0;i < ThemeList.Length;i++)
    {
        if( PlayerName == ThemeList[i].PlayerName){
            return ThemeList[i].SoundName;
        }
    }

    return ThemeList[0].SoundName;
}

function AddThemeToQueue(String PlayerName){
    local sound PlayerSound;

    PlayerSound = GetPlayerTheme(PlayerName);

    AddToQueue(PlayerName, PlayerSound);
}

function AddToQueue(String PlayerName, sound SoundName){
    local int newIndex;

    newIndex = QueueList.Length;
    QueueList.Insert(newIndex,1);
    QueueList[newIndex].PlayerName = PlayerName;
    QueueList[newIndex].SoundName = SoundName;
    SetTimer(10.0,true);
}

function PlayQueue(){
    local int i;
    local PlayerController c;

    for(i=0;i < QueueList.Length;i++)
    {
        c = getPlayerController(QueueList[i].PlayerName);
        if( c != none && c.Pawn != none){

            PlayTheme(QueueList[i].PlayerName);

            Level.Game.AdminSay(QueueList[i].PlayerName);

            QueueList.Remove(i,1);
            if(QueueList.Length ==0){
                SetTimer(0.0,false);
                return;
            }

        }
    }
}

function PlayerController getPlayerController(String PlayerName){
    local PlayerController c;

    foreach DynamicActors(class'PlayerController', c){
        if(C.PlayerReplicationInfo != none){
            if(PlayerName == C.PlayerReplicationInfo.PlayerName){
                return c;
            }
        }
    }
}

function PlayTrigger(String TriggerName){
    local int i;
    local PlayerController c;

    for(i=0;i < TriggerList.Length;i++)
    {
        if( TriggerName == TriggerList[i].TriggerName){
            foreach DynamicActors(class'PlayerController', c){
                 c.PlayAnnouncement(TriggerList[i].SoundName, 1, true);
            }
        }
    }

    for(i=0;i < ThemeList.Length;i++)
    {
        if( TriggerName == ThemeList[i].PlayerName){
            foreach DynamicActors(class'PlayerController', c){
                 c.PlayAnnouncement(ThemeList[i].SoundName, 1, true);
            }
        }
    }

}

function ModifyLogin (out string Portal, out string Options){
    local String sNick;

    super.ModifyLogin(Portal,Options);

    if(bInProgress){
        sNick = Level.Game.ParseOption(Options,"name");
        AddThemeToQueue(sNick);
    }

}

function ModifyPlayer(Pawn Other){
    super.ModifyPlayer(Other);
    bInProgress=true;
}

function NotifyLogout(Controller Exiting)
{
    if(!Exiting.PlayerReplicationInfo.bBot)
    {
        PlayTheme(Exiting.PlayerReplicationInfo.PlayerName);
    }

    if(NextMutator != none)
    {
        NextMutator.NotifyLogout(Exiting);
    }

}

function Mutate (string MutateString, PlayerController Sender){
    PlayTrigger(MutateString);

    if ( NextMutator != None )
    {
        NextMutator.Mutate(MutateString,Sender);
    }
}

defaultproperties
{
     ThemeList(0)=(PlayerName="hi",SoundName=Sound'Banyan.Generic.HiDee')
     ThemeList(1)=(PlayerName="GigaWatt",SoundName=Sound'Banyan.Generic.Maya')
     ThemeList(2)=(PlayerName="Matt",SoundName=Sound'Banyan.Generic.Maya')
     ThemeList(3)=(PlayerName="Thrillho",SoundName=Sound'Banyan.Generic.Thril')
     ThemeList(4)=(PlayerName="AdmiralAckbar",SoundName=Sound'Banyan.Generic.Ackbar')
     ThemeList(5)=(PlayerName="Glitch",SoundName=Sound'Banyan.Generic.Surf')
     ThemeList(6)=(PlayerName="iota",SoundName=Sound'Banyan.Generic.Alive')
     ThemeList(7)=(PlayerName="Thunder",SoundName=Sound'Banyan.Generic.Thunder')
     ThemeList(8)=(PlayerName="BloodyRedBaron",SoundName=Sound'Banyan.Generic.BRB')
     ThemeList(9)=(PlayerName="KOWTiPA",SoundName=Sound'Banyan.Generic.Cow')
     ThemeList(10)=(PlayerName="TheDecoy",SoundName=Sound'Banyan.Generic.Decoy')
     ThemeList(11)=(PlayerName="KangarooKicker",SoundName=Sound'Banyan.Generic.Maya')
     ThemeList(12)=(PlayerName="CorporateTool",SoundName=Sound'Banyan.Generic.Tool')
     ThemeList(13)=(PlayerName="Dasbender",SoundName=Sound'Banyan.Generic.Bender')
     ThemeList(14)=(PlayerName="Wolfenstein",SoundName=Sound'Banyan.Generic.Wolf')
     ThemeList(15)=(PlayerName="GreyDwarf",SoundName=Sound'Banyan.Generic.Dwarf')
     ThemeList(16)=(PlayerName="PerpetualOffense",SoundName=Sound'Banyan.Generic.Mario')
     ThemeList(17)=(PlayerName="Squirt",SoundName=Sound'Banyan.Generic.Squirt')
     ThemeList(18)=(PlayerName="fly",SoundName=Sound'Banyan.Generic.Fly')
     ThemeList(19)=(PlayerName="Escape",SoundName=Sound'Banyan.Generic.Escape')
     ThemeList(20)=(PlayerName="Brumdail",SoundName=Sound'Banyan.Generic.Maya')
     ThemeList(21)=(PlayerName="kludge",SoundName=Sound'Banyan.Generic.Trooper')
     ThemeList(22)=(PlayerName="BIGPOP_4",SoundName=Sound'Banyan.Generic.Poppa')
     TriggerList(0)=(TriggerName="stop",SoundName=Sound'GlitchModSounds.WeCantStop')
     TriggerList(1)=(TriggerName="stigmatta",SoundName=Sound'Banyan.Generic.Stigmatta')
     TriggerList(2)=(TriggerName="AnimalRights",SoundName=Sound'GlitchModSounds.AnimalRights')
     TriggerList(3)=(TriggerName="Body",SoundName=Sound'GlitchModSounds.Body')
     TriggerList(4)=(TriggerName="CantKill",SoundName=Sound'GlitchModSounds.CantKill')
     TriggerList(5)=(TriggerName="Control",SoundName=Sound'GlitchModSounds.Control')
     TriggerList(6)=(TriggerName="DevilsDen",SoundName=Sound'GlitchModSounds.DevilsDen')
     TriggerList(7)=(TriggerName="Digitalism",SoundName=Sound'GlitchModSounds.Digitalism')
     TriggerList(8)=(TriggerName="Doom",SoundName=Sound'GlitchModSounds.Doom')
     TriggerList(9)=(TriggerName="DropDead",SoundName=Sound'GlitchModSounds.DropDead')
     TriggerList(10)=(TriggerName="IAm",SoundName=Sound'GlitchModSounds.IAm')
     TriggerList(11)=(TriggerName="Lick",SoundName=Sound'GlitchModSounds.Lick')
     TriggerList(12)=(TriggerName="Matrix",SoundName=Sound'GlitchModSounds.Matrix')
     TriggerList(13)=(TriggerName="MeAndYou",SoundName=Sound'GlitchModSounds.MeAndYou')
     TriggerList(14)=(TriggerName="OhMyGod",SoundName=Sound'GlitchModSounds.OhMyGod')
     TriggerList(15)=(TriggerName="OhYea",SoundName=Sound'GlitchModSounds.OhYea')
     TriggerList(16)=(TriggerName="RaiseYourWeapon",SoundName=Sound'GlitchModSounds.RaiseYourWeapon')
     TriggerList(17)=(TriggerName="Slam",SoundName=Sound'GlitchModSounds.Slam')
     TriggerList(18)=(TriggerName="Timestretch",SoundName=Sound'GlitchModSounds.Timestretch')
     TriggerList(19)=(TriggerName="WeCantStop",SoundName=Sound'GlitchModSounds.WeCantStop')
     bAddToServerPackages=True
     GroupName="WSounds"
     FriendlyName="WumpusSounds"
     Description="Add Sounds for Player Themes and fun."
}
