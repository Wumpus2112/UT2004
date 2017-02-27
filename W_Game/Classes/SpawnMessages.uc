class SpawnMessages extends LocalMessage;

var localized string    SpawnDelay;

static function string GetString(
    optional int Delay,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return default.SpawnDelay@(Delay);
}

defaultproperties
{
     SpawnDelay="Respawn in : "
     bIsUnique=True
     bFadeMessage=True
     Lifetime=1
     DrawColor=(B=128,G=0)
     StackMode=SM_Down
     PosY=0.100000
}
