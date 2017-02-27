//-----------------------------------------------------------
//
//-----------------------------------------------------------
class wTeamGame extends xTeamGame;

event PlayerController Login( string Portal, string Options, out string Error ){
    local PlayerController pc;

    pc = super.Login(Portal, Options, Error);

    if(pc != None){
        pc.PawnClass = class'W_Game.xWumpusPawn';
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
        B.PawnClass = class'W_Game.xWumpusPawn';
    }
    return B;
}

defaultproperties
{
     GameName="W Team DeathMatch"
     Acronym="WTDM"
}
