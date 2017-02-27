//-----------------------------------------------------------
//
//-----------------------------------------------------------
class xVehicleBRGame extends xBombingRun;


function bool AllowTransloc()
{
	return false;
}

static function bool NeverAllowTransloc()
{
	return true;
}

function ScoreBomb(Controller Scorer, xBombFlag theFlag)
{
    super.ScoreBomb(Scorer, theFlag);
    log("Checking Ball");
    if (Scorer.PlayerReplicationInfo.HasFlag == None)return;
    log("Scorer Has ball");
    Scorer.PlayerReplicationInfo.HasFlag = none;
    theFlag.ClearHolder();
    theFlag.Reset();
    Scorer.SwitchToBestWeapon();

}


defaultproperties
{
     bAllowTrans=False
     bDefaultTranslocator=False
     bAllowVehicles=True
     MapListType="XInterface.MapListVehicleCTF"
     MapPrefix="VBR"
     BeaconName="VBR"
     GameName="Vehicle BR"
     Description="Like traditional Bombing Run, only adding vehicles into the mix! Only ground-based vehicles can carry the ball."
     ScreenShotName="UT2004Thumbnails.VCTFShots"
     DecoTextName="XGame.xVehicleBRGame"
     Acronym="VBR"
}

