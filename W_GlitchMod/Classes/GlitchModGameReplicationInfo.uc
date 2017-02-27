class GlitchModGameReplicationInfo extends GameReplicationInfo;

var int GlitchNumber;

replication
{
    reliable if(Role == ROLE_Authority)
         GlitchNumber;
}

defaultproperties
{
     NetUpdateFrequency=1.000000
     bNetNotify=True
}
