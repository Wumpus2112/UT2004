/*******************************************************************************
 * QuantumWatcher generated by Eliot.UELib using UE Explorer.
 * Eliot.UELib ? 2009-2013 Eliot van Uytfanghe. All rights reserved.
 * http://eliotvu.com
 *
 * All rights belong to their respective owners.
 *******************************************************************************/
class QuantumWatcherDELETEME extends ReplicationInfo
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var int QuantumLimit;
var bool bLimitReached;
var bool bPrevLimitReached;
var int nVorticesActive;
var float QuantumEndTime;

replication
{

    reliable if(Role == ROLE_Authority)
        bLimitReached;
}

function PostBeginPlay()
{
    QuantumLimit = 0;
    //return;
}

function AddQuantum(PlayerReplicationInfo QuantumOwnerPRI)
{
    ++ nVorticesActive;
    // End:0x5D
    if(!bLimitReached)
    {
        bLimitReached = ((QuantumLimit != 0) && QuantumLimit > 0) && nVorticesActive >= QuantumLimit;
        // End:0x5D
        if(bLimitReached)
        {
//            BroadcastLocalizedMessage(class'QuantumLimitMessage', QuantumLimit, QuantumOwnerPRI);
        }
    }
    // End:0x8B
    if(bLimitReached)
    {
        QuantumEndTime = Level.TimeSeconds + class'QuantumProj'.static.GetQuantumDuration();
    }
    //return;
}

function RemoveQuantum()
{
    -- nVorticesActive;
    bLimitReached = (QuantumLimit > 0) && nVorticesActive >= QuantumLimit;
    //return;
}

simulated function bool QuantumLimitReached()
{
    return bLimitReached;
    //return;
}

simulated function PostNetReceive()
{
    // End:0x3B
    if(bLimitReached && !bPrevLimitReached)
    {
        QuantumEndTime = Level.TimeSeconds + class'QuantumProj'.static.GetQuantumDuration();
    }
    bPrevLimitReached = bLimitReached;
    //return;
}

defaultproperties
{
    bNetNotify=true
}