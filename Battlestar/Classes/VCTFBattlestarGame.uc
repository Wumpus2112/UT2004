//-----------------------------------------------------------
//
//-----------------------------------------------------------
class VCTFBattlestarGame extends xVehicleCTFGame;

state MatchInProgress
{
    function Timer()
    {
        local Controller  C;
        local xWumpusPlayer  WC;

        super.Timer();

        for( C = Level.ControllerList; C != None; C = C.NextController ){
            WC = xWumpusPlayer(C);
            if(WC != none){
                if(WC.bWaiting){
                    WC.spawnWait--;
                    if(WC.spawnWait < 1){
                        WC.bWaiting = false;
                        RestartPlayer(WC);
                    }else{
                        SendSpawnWait(WC,WC.spawnWait);
                    }
                }else{
                    if(WC.IsDead()){
                        setRespawn(WC);
                    }
                }

                if(WC.IsDead() && !WC.bWaiting){
                    WC.bWaiting = true;
                    WC.spawnWait = 6;
                }
            }

        }
    }

    function SendSpawnWait(PlayerController Player, int secondsLeft){
        if(Player != none){
         //      Player.ReceiveLocalizedMessage(class'WumpusPack.SpawnMessages', secondsLeft);
        }

    }

    function RestartPlayer( Controller aPlayer )
    {
        aPlayer.UnPossess();
        super.RestartPlayer( aPlayer );
    }

    function ScoreKill(Controller killer, Controller target){

        if(target.Pawn != none && target.Pawn.IsHumanControlled()){
            if(target.Pawn.Controller != none){
                setRespawn(xWumpusPlayer(target));
            }
        }
        super.ScoreKill(killer,target);

    }

    function setRespawn(xWumpusPlayer WP){
        local int spawnWait;
        if(WP != none){
            WP.bWaiting = true;
            spawnWait = 6 + WP.PlayerReplicationInfo.Score/10;
            if(spawnWait < 6) spawnWait = 6;
            if(spawnWait > 11) spawnWait =11;
            WP.spawnWait = spawnWait;
        }else{
            log("ERROR: Huge Problem! Not a Wumpus Controller!!!");
        }
    }

    function bool PlayerCanRestart( PlayerController aPlayer )
    {
        local xWumpusPlayer WP;
        WP = xWumpusPlayer(aPlayer);
        if(WP != none && !WP.bWaiting){
            setRespawn(WP);
        }
        return false;
    }

    function bool PlayerCanRestartGame( PlayerController aPlayer )
    {
        local xWumpusPlayer WP;
        WP = xWumpusPlayer(aPlayer);
        if(WP != none && !WP.bWaiting){
            setRespawn(WP);
        }
        return false;
    }

}

function EndGame(PlayerReplicationInfo Winner, string Reason )
{
    local Controller  C;
    local xWumpusPlayer  WC;

    for( C = Level.ControllerList; C != None; C = C.NextController ){
        WC = xWumpusPlayer(C);
        if(WC != none){
            if(WC.bWaiting){
                    WC.bWaiting = false;
                    RestartPlayer(WC);
            }
        }
    }

    super.EndGame(Winner, Reason );
}

DefaultProperties
{
    Acronym="BVCF"
    GameName="Battlestar VCTF"
    Description="Battlestar Vehicle Capture The Flag, with Spawn Delay"

    DefaultPlayerClassName="WumpusPack.xWumpusPawn"
    PlayerControllerClassName="WumpusPack.xWumpusPlayer"
}
