//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WumpusTeamsReplicationInfo extends ReplicationInfo;

var string RedTeam[16];
var string BlueTeam[16];
var string GreyTeam[32];

var string RedCaptainName;
var string BlueCaptainName;

var int RedCount;
var int BlueCount;
var int GreyCount;
var int CurrentCaptain;
var int PickingStatus;
var int CountDown;

replication
{
    reliable if(Role == ROLE_Authority)
         RedCaptainName, BlueCaptainName, RedTeam, BlueTeam, GreyTeam, RedCount, BlueCount, GreyCount, CurrentCaptain, PickingStatus, CountDown;

}

defaultproperties
{
     NetUpdateFrequency=1.000000
     bNetNotify=True
}
