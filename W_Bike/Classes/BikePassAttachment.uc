//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BikePassAttachment extends ONSWeapon;

simulated function PostBeginPlay()
{
    Enable('Timer');
    SetTimer(1.0, true);
    super.PostBeginPlay();
    //return;
}

function Timer()
{
    // End:0x12
    if(Role != ROLE_Authority)
    {
        return;
    }
    // End:0x20
    if(Instigator == none)
    {
        Destroy();
    }
    //return;
}

defaultproperties
{
    YawBone=Object01
    PitchBone=Object02
    GunnerAttachmentBone=PassengerLocation
    Mesh=SkeletalMesh'BattleBikes_Anim.PassengerGun'
    DrawScale=0.850
}
