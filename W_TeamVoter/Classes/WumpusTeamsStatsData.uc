//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WumpusTeamsStatsData extends Actor
      config(W_TeamVoterData);

// Per match stats
struct PlayerStats
{
    var string sName;
    var float iScore;
};

var protected config array<PlayerStats> stPlayerStats;

function Clear(){
    stPlayerStats.Remove(0,stPlayerStats.Length);
}

function AddPlayer(string sPlayerName, float score)
{
    local int iIndex;

    if (sPlayerName == "")
        return;

    iIndex = FindPlayerIndex(sPlayerName);

    if (iIndex == -1)
    {
        iIndex = stPlayerStats.Length;
        stPlayerStats.Insert(iIndex, 1);
        stPlayerStats[iIndex].sName = sPlayerName;
    }

    stPlayerStats[iIndex].iScore = score;
}

function int getNumberOfPlayers(){
    return stPlayerStats.Length;
}

function String GetPlayerName(int iIndex){
    return stPlayerStats[iIndex].sName;
}
function int GetPlayerScore(int iIndex){
    return stPlayerStats[iIndex].iScore;
}

function int FindPlayerIndex(string sPlayerName)
{
    local int iIndex;

    for (iIndex = 0; iIndex < stPlayerStats.Length; iIndex++)
        if (stPlayerStats[iIndex].sName == sPlayerName)
            return (iIndex);

    return (-1);
}

function String GetSerializedData(){
    local string SerializedData;
    local int iIndex;

    stPlayerStats = default.stPlayerStats;
    SerializedData = "";
    for (iIndex = 0; iIndex < stPlayerStats.Length; iIndex++){
        SerializedData = SerializedData$"|"$stPlayerStats[iIndex].sName$":"$stPlayerStats[iIndex].iScore;
    }
    return SerializedData;
}

function SaveSettings()
{
    SaveConfig();
}

defaultproperties
{
     stPlayerStats(0)=(sName="Glitch",iScore=15.000000)
}
