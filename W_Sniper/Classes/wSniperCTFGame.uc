//-----------------------------------------------------------
//
//-----------------------------------------------------------
class wSniperCTFGame extends xCTFGame;

event PlayerController Login( string Portal, string Options, out string Error ){
    local PlayerController pc;

    pc = super.Login(Portal, Options, Error);

    if(pc != None){
        pc.PawnClass = class'W_Sniper.xWumpusRadarPawn';
    }

    return pc;
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
     DefaultEnemyRosterClass="xGame.xTeamRoster"
     HUDType="XInterface.HudCCaptureTheFlag"
     MapListType="XInterface.MapListCaptureTheFlag"
     DeathMessageClass=Class'XGame.xDeathMessage'
     OtherMesgGroup="CTFGame"
     ScreenShotName="UT2004Thumbnails.CTFShots"
     DecoTextName="XGame.CTFGame"

     MutatorClass="W_Sniper.MutWumpusSniper"
     ResetTimeDelay=11
     GameName="Sniper Capture the Flag"
     Description="Sniper Team Capture the Flag*"
     Acronym="SCTF"

     bForceDefaultCharacter=true
}
