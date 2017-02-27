//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WTransFire extends TransFire;

function Projectile SpawnProjectile (Vector Start, Rotator Dir)
{
  local TransBeacon TransBeacon;

  if ( Class'MutWTranslocator'.Default.bDisableTrails == False )
  {
    if ( Translauncher(Weapon).TransBeacon == None )
    {
      class'WTransBeacon'.Default.Speed = class'MutWTranslocator'.Default.TossForce;
//      class'WRedBeacon'.Default.Speed = class'MutWTranslocator'.Default.TossForce;
//      Class'WBlueBeacon'.Default.Speed = Class'MutWTranslocator'.Default.TossForce;
//      Class'WGreenBeacon'.Default.Speed = Class'MutWTranslocator'.Default.TossForce;
//      Class'WGoldBeacon'.Default.Speed = Class'MutWTranslocator'.Default.TossForce;
//      if ( (Instigator == None) || (Instigator.PlayerReplicationInfo == None) || (Instigator.PlayerReplicationInfo.Team == None) )
//      {
        TransBeacon = Weapon.Spawn(Class'WTransBeacon',,,Start,Dir);
//      } else {
/*        if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
        {
          TransBeacon = Weapon.Spawn(Class'WRedBeacon',,,Start,Dir);
        } else {
          if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 1 )
          {
            TransBeacon = Weapon.Spawn(Class'WBlueBeacon',,,Start,Dir);
          } else {
            if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 2 )
            {
              TransBeacon = Weapon.Spawn(Class'WGreenBeacon',,,Start,Dir);
            } else {
              if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 3 )
              {
                TransBeacon = Weapon.Spawn(Class'WGoldBeacon',,,Start,Dir);
              } else {
                TransBeacon = Weapon.Spawn(Class'WBlueBeacon',,,Start,Dir);
              }
            }
          }
        }

      }
      */
      Translauncher(Weapon).TransBeacon = TransBeacon;
      Weapon.PlaySound(TransFireSound,SLOT_Interact,,,,,false);
    } else {
      Translauncher(Weapon).ViewPlayer();
      if ( Translauncher(Weapon).TransBeacon.Disrupted() )
      {
        if ( (Instigator != None) && (PlayerController(Instigator.Controller) != None) )
        {
          PlayerController(Instigator.Controller).ClientPlaySound(Sound'BSeekLost1');
        }
      } else {
        Translauncher(Weapon).TransBeacon.Destroy();
        Translauncher(Weapon).TransBeacon = None;
        Weapon.PlaySound(RecallFireSound,SLOT_Interact,,,,,false);

      }
    }
    return TransBeacon;
  } else {
    if ( Class'MutWTranslocator'.Default.bDisableTrails )
    {
      if ( Translauncher(Weapon).TransBeacon == None )
      {
        ProjectileClass = class'W_Sniper.WTransBeaconNT';
        Class'WTransBeaconNT'.Default.Speed = Class'MutWTranslocator'.Default.TossForce;
//        Class'WRedBeaconNT'.Default.Speed = Class'MutWTranslocator'.Default.TossForce;
//        Class'WBlueBeaconNT'.Default.Speed = Class'MutWTranslocator'.Default.TossForce;
//        Class'WGreenBeaconNT'.Default.Speed = Class'MutWTranslocator'.Default.TossForce;
 //       Class'WGoldBeaconNT'.Default.Speed = Class'MutWTranslocator'.Default.TossForce;
//        if ( (Instigator == None) || (Instigator.PlayerReplicationInfo == None) || (Instigator.PlayerReplicationInfo.Team == None) )
//        {
          TransBeacon = Weapon.Spawn(Class'WTransBeaconNT',,,Start,Dir);
/*        } else {
          if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
          {
            TransBeacon = Weapon.Spawn(Class'WRedBeaconNT',,,Start,Dir);
          } else {
            if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 1 )
            {
              TransBeacon = Weapon.Spawn(Class'WBlueBeaconNT',,,Start,Dir);
            } else {
              if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 2 )
              {
                TransBeacon = Weapon.Spawn(Class'WGreenBeaconNT',,,Start,Dir);
              } else {
                if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 3 )
                {
                  TransBeacon = Weapon.Spawn(Class'WGoldBeaconNT',,,Start,Dir);
                } else {
                  TransBeacon = Weapon.Spawn(Class'WBlueBeaconNT',,,Start,Dir);
                }
              }
            }
          }
        }
*/
        Translauncher(Weapon).TransBeacon = TransBeacon;
        Weapon.PlaySound(TransFireSound,SLOT_Interact,,,,,false);

      } else {
        Translauncher(Weapon).ViewPlayer();
        if ( Translauncher(Weapon).TransBeacon.Disrupted() )
        {
          if ( (Instigator != None) && (PlayerController(Instigator.Controller) != None) )
          {
            PlayerController(Instigator.Controller).ClientPlaySound(Sound'BSeekLost1');
          }
        } else {
          Translauncher(Weapon).TransBeacon.Destroy();
          Translauncher(Weapon).TransBeacon = None;
            Weapon.PlaySound(RecallFireSound,SLOT_Interact,,,,,false);
        }
      }
      return TransBeacon;
    }
  }
}

defaultproperties
{
     FireRate=2.000000
     ProjectileClass=Class'W_Sniper.WTransBeaconNT'
}
