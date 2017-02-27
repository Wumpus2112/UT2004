//-----------------------------------------------------------
//
//-----------------------------------------------------------
class wDeathMatch extends xDeathMatch;

// Change the default pawn class to xCamperPawn on login.
event PlayerController Login( string Portal, string Options, out string Error ){
    local PlayerController pc;

    pc = super.Login(Portal, Options, Error);

    if(pc != None){
        pc.PawnClass = class'W_Game.xWumpusPawn';
    }

    return pc;
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
     GameName="W DeathMatch"
     Acronym="WDM"
}
