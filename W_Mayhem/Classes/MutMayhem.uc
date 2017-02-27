//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutMayhem extends Mutator;

auto state startup
{
	function tick(float deltatime)
	{
		Level.GRI.WeaponBerserk = 3;
		GotoState('BegunPlay');
	}
}


state BegunPlay
{
	ignores tick;
}

function Timer()
{
    local xPawn x;
    local Inventory Inv;

    super.Timer();

    foreach DynamicActors(class'xPawn', x){
        for ( Inv=x.Inventory; Inv!=None; Inv=Inv.Inventory )
        {
            if ( Weapon(Inv) != None )
                Weapon(Inv).SuperMaxOutAmmo();
        }
    }
}

function PostBeginPlay()
{
    Initialize();
    Super.PostBeginPlay();
}

function Initialize(){
    Level.GRI.WeaponBerserk = 3;
    SetTimer(10.0,true);
}

function ModifyPlayer(Pawn Other)
{
    local xPawn x;
    local Inventory Inv;

    super.ModifyPlayer(Other);

//    Other.ShieldStrength = 150;
//    Other.Health = 199;
    x = xPawn(Other);
    if(x != None)
    {

//        x.Health = 199;
//        x.ShieldStrength=150;
        x.CreateInventory("XWeapons.BioRifle");
        x.CreateInventory("XWeapons.FlakCannon");
        x.CreateInventory("XWeapons.LinkGun");
        x.CreateInventory("XWeapons.Minigun");
        x.CreateInventory("XWeapons.RocketLauncher");
        x.CreateInventory("XWeapons.ShockRifle");
        x.CreateInventory("XWeapons.SniperRifle");

        for ( Inv=x.Inventory; Inv!=None; Inv=Inv.Inventory )
        {
            if ( Weapon(Inv) != None )
                Weapon(Inv).SuperMaxOutAmmo();
        }

    }

}


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{

    local xWeaponBase B;
    local Pickup P;
    local TournamentPickup T;

    B = xWeaponBase(Other);
    if ( B != none )
        B.bHidden = true;

    P = Pickup(Other);
    if ( P != none ){
      T = TournamentPickup(P);
      if(T == none){
            P.Destroy();
      }
    }


    return true;
}

defaultproperties
{
    GroupName="Full Loadout"
    FriendlyName="Full Loadout"
    Description="Full Loadout"
}
