//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WumpusBalancerStatsData extends Object
      config(WumpusBalancerStatsData);

// Per match stats
struct PlayerStruct
{
    var string sName;
    var float iScore;
};

var protected config array<PlayerStruct> stCurrentPlayers;
var protected config array<PlayerStruct> stPlayerRankings;

function Clear(){
    stCurrentPlayers.Remove(0,stCurrentPlayers.Length);
}

function AddPlayer(string sPlayerName)
{
    local int iIndex;

    if (sPlayerName == "")
        return;

    iIndex = FindPlayerIndex(sPlayerName);

    if (iIndex == -1)
    {
        iIndex = stCurrentPlayers.Length;
        stCurrentPlayers.Insert(iIndex, 1);
        stCurrentPlayers[iIndex].sName = sPlayerName;
    }

    stCurrentPlayers[iIndex].iScore = getPlayerRanking(sPlayerName);
}

function int getNumberOfPlayers(){
    return stCurrentPlayers.Length;
}

function String GetPlayerName(int iIndex){
    return stCurrentPlayers[iIndex].sName;
}
function int GetPlayerScore(int iIndex){
    return stCurrentPlayers[iIndex].iScore;
}

function int FindPlayerIndex(string sPlayerName)
{
    local int iIndex;

    for (iIndex = 0; iIndex < stCurrentPlayers.Length; iIndex++)
        if (stCurrentPlayers[iIndex].sName == sPlayerName)
            return (iIndex);

    return (-1);
}
/*
function String GetSerializedData(){
    local string SerializedData;
    local int iIndex;

    stPlayerStats = default.stPlayerStats;
    SerializedData = "";
    for (iIndex = 0; iIndex < stCurrentPlayers.Length; iIndex++){
        SerializedData = SerializedData$"|"$stCurrentPlayers[iIndex].sName$":"$stCurrentPlayers[iIndex].iScore;
    }
    return SerializedData;
}
*/
function float getPlayerRanking(String sPlayerName){

    local int iIndex;

    for (iIndex = 0; iIndex < stPlayerRankings.Length; iIndex++)
        if (stPlayerRankings[iIndex].sName == sPlayerName)
            return (stPlayerRankings[iIndex].iScore);

    // player not found add player
    iIndex = stPlayerRankings.Length;
    stPlayerRankings.Insert(iIndex, 1);
    stPlayerRankings[iIndex].sName = sPlayerName;
    stPlayerRankings[iIndex].iScore = 1;

    return (0);
}


function SaveSettings()
{
    SaveConfig();
}

defaultproperties
{
     stCurrentPlayers(0)=(sName="Zarina *",iScore=-99.000000)
     stCurrentPlayers(1)=(sName="Brock *",iScore=-99.000000)
     stCurrentPlayers(2)=(sName="Divisor *",iScore=-99.000000)
     stCurrentPlayers(3)=(sName="Corrosion *",iScore=-99.000000)
     stCurrentPlayers(4)=(sName="Skrilax *",iScore=-99.000000)
     stCurrentPlayers(5)=(sName="Gorge *",iScore=-99.000000)
     stCurrentPlayers(6)=(sName="Othello *",iScore=-99.000000)
     stCurrentPlayers(7)=(sName="Sarge",iScore=5.000000)
}
