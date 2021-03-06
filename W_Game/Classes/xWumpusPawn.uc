class xWumpusPawn extends xPawn;

var             float       wumpusProtectTime;
var             bool        bWumpusProtect;


var class<Actor>    tempTeleportFXClass;
var class<Actor>    tempTransEffects[2];
var class<Actor>    tempTransOutEffect[2];

event PostBeginPlay(){
    SpawnProtect();
    super.PostBeginPlay();
}

simulated function StartFiring(bool bHeavy, bool bRapid){
    if(bWumpusProtect) SpawnUnprotect();
    super.StartFiring(bHeavy,bRapid);
}

simulated function Tick(float DeltaTime){
    super.Tick(DeltaTime);
    if(bWumpusProtect){
        wumpusProtectTime -= DeltaTime;
        if(wumpusProtectTime < 0.0){
            SpawnUnprotect();
        }
    }
}

simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType){
    if(bWumpusProtect) return;
    super.TakeDamage( Damage, InstigatedBy, Hitlocation, Momentum,  damageType);
}

simulated function SpawnUnprotect(){
    SetInvisibility(0.0);
    bInvulnerableBody = false;

    TransOutEffect[0] = tempTransOutEffect[0];
    TransOutEffect[1] = tempTransOutEffect[1];
    TransEffects[0] = tempTransEffects[0];
    TransEffects[1] = tempTransEffects[1];
    TeleportFXClass = tempTeleportFXClass;
    bWumpusProtect = false;
}


simulated function SpawnProtect(){
    wumpusProtectTime = DeathMatch(Level.Game).SpawnProtectionTime;

    SetInvisibility(0.1);
    bInvulnerableBody = true;

    tempTransOutEffect[0] = TransOutEffect[0];
    tempTransOutEffect[1] = TransOutEffect[1];
    tempTransEffects[0] = TransEffects[0];
    tempTransEffects[1] = TransEffects[1];
    tempTeleportFXClass = TeleportFXClass;

    TransOutEffect[0] = none;
    TransOutEffect[1] = none;
    TransEffects[0] = none;
    TransEffects[1] = none;
    TeleportFXClass = none;

    bWumpusProtect = true;
}

defaultproperties
{
}
