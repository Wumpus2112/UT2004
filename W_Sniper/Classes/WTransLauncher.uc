//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WTransLauncher extends TransLauncher
  config(User);

var bool RepbShowChargingBar;

replication
{
  unreliable if ( Role == 4 )
    RepbShowChargingBar;
}

simulated function PostNetBeginPlay ()
{
  Super.PostNetBeginPlay();
  if ( Level.NetMode == 3 )
  {
    bShowChargingBar = RepbShowChargingBar;
  }
  if ( (Level.NetMode == 1) || (Level.NetMode == 2) )
  {
    RepbShowChargingBar = bShowChargingBar;
  }
  if ( RepbShowChargingBar == False )
  {
    AmmoChargeF = 1.0;
    RepAmmo = 1;
    AmmoChargeMax = 1.0;
    AmmoChargeRate = 10.0;
  }
  if ( RepbShowChargingBar )
  {
    AmmoChargeF = 6.0;
    RepAmmo = 6;
    AmmoChargeMax = 6.0;
    AmmoChargeRate = 0.41;
  }
}

simulated event RenderOverlays (Canvas Canvas)
{
  local float tileScaleX;
  local float tileScaleY;
  local float dist;
  local float clr;
  local float NewTranslocScale;

  if ( PlayerController(Instigator.Controller).ViewTarget == TransBeacon )
  {
    tileScaleX = Canvas.SizeX / 640.0;
    tileScaleY = Canvas.SizeY / 480.0;
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 255;
    Canvas.DrawColor.A = 255;
    Canvas.Style = 255;
    Canvas.SetPos(0.0,0.0);
    Canvas.DrawTile(FinalBlend'TransCamFB',Canvas.SizeX,Canvas.SizeY,0.0,0.0,512.0,512.0);
    Canvas.SetPos(0.0,0.0);
    if (  !Level.IsSoftwareRendering() )
    {
      dist = VSize(TransBeacon.Location - Instigator.Location);
      if ( dist > MaxCamDist )
      {
        clr = 255.0;
      } else {
        clr = dist / MaxCamDist;
        clr *= 255.0;
      }
      clr = Clamp(int(clr),20,255);
      Canvas.DrawColor.R = byte(clr);
      Canvas.DrawColor.G = byte(clr);
      Canvas.DrawColor.B = byte(clr);
      Canvas.DrawColor.A = 255;
      Canvas.DrawTile(FinalBlend'ScreenNoiseFB',Canvas.SizeX,Canvas.SizeY,0.0,0.0,512.0,512.0);
    }
  } else {
    if ( TransBeacon == None )
    {
      NewTranslocScale = 1.0;
    } else {
      NewTranslocScale = 0.0;
    }
    if ( NewTranslocScale != TranslocScale )
    {
      TranslocScale = NewTranslocScale;
      SetBoneScale(0,TranslocScale,'Beacon');
    }
    if ( TranslocScale != 0 )
    {
      TranslocRot.Yaw += int(120000 * (Level.TimeSeconds - OldTime));
      OldTime = Level.TimeSeconds;
      SetBoneRotation('Beacon',TranslocRot,0);
    }
    if (  !bTeamSet && (Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.Team != None) )
    {
      bTeamSet = True;
      if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 1 )
      {
        Skins[1] = TexPanner'InvisPanner';
      }
    }
    Super.RenderOverlays(Canvas);
  }
}
/*
function Class<DamageType> GetDamageType ()
{
  return Class'DamTypeXxxXTeleFrag';
}
*/

defaultproperties
{
     FireModeClass(0)=Class'W_Sniper.WTransFire'
     Description="W Translocator"
     AttachmentClass=Class'W_Sniper.WTransAttachment'
     ItemName="Wumpus Transloc"
}
