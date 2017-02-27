//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HoverboardLauncherFire extends ProjectileFire;

simulated function bool AllowFire ()
{
  return True;
}

function Projectile SpawnProjectile (Vector Start, Rotator Dir)
{
  local Hoverboard Board;
  local Vector ThrowDir;

  ThrowDir = Start + (vect(450.00,0.00,150.00) >> Instigator.Rotation);
  Board = Weapon.Spawn(class'Hoverboard',Instigator,,ThrowDir,Instigator.Rotation);
  Board.SetTeamNum(Instigator.GetTeamNum());
  Board.KAddImpulse(vect(100000.00,0.00,0.00) >> Board.Rotation,Board.Location);
  Board.TryToDrive(Instigator);
  return None;
}

defaultproperties
{
    bWaitForRelease=True

    bModeExclusive=False

    FireSound=Sound'WeaponSounds.Misc.ballgun_launch'

    FireForce="ballgun_launch"

    FireRate=2.25

    AmmoClass=class'HoverboardLauncherAmmo'

}