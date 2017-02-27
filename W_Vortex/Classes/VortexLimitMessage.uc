/*******************************************************************************
 * VortexLimitMessage generated by Eliot.UELib using UE Explorer.
 * Eliot.UELib ? 2009-2013 Eliot van Uytfanghe. All rights reserved.
 * http://eliotvu.com
 *
 * All rights belong to their respective owners.
 *******************************************************************************/
class VortexLimitMessage extends LocalMessage
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var localized string LimitOneText;
var localized string LimitMoreText;
var localized string LimitActiveText;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local string S;

    // End:0x14
    if(Switch == 0)
    {
        return default.LimitActiveText;
    }
    // End:0x4F
    else
    {
        // End:0x28
        if(Switch == 1)
        {
            return default.LimitOneText;
        }
        // End:0x4F
        else
        {
            S = default.LimitMoreText;
            StaticReplaceText(S, "%n", string(Switch));
            return S;
        }
    }
    return "";
    //return;    
}

static simulated function ClientReceive(PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    // End:0x64
    if((Switch == 0) || (PlayerHasVortex(P)) && (P.PlayerReplicationInfo != RelatedPRI_1) || Switch > 1)
    {
        super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    }
    // End:0x66
    else
    {
        return;
    }
    //return;    
}

static simulated function bool PlayerHasVortex(PlayerController P)
{
    local Inventory thisItem;

    // End:0x16
    if(P.Pawn == none)
    {
        return false;
    }
    thisItem = P.Pawn.Inventory;
    J0x33:
    // End:0x7A [Loop If]
    if(thisItem != none)
    {
        // End:0x63
        if(Vortex(thisItem) != none)
        {
            return Vortex(thisItem).HasAmmo();
        }
        thisItem = thisItem.Inventory;
        // [Loop Continue]
        goto J0x33;
    }
    return false;
    //return;    
}

static final function StaticReplaceText(out string Text, string Replace, string With)
{
    local int i;
    local string Input;

    Input = Text;
    Text = "";
    i = InStr(Input, Replace);
    J0x25:
    // End:0x84 [Loop If]
    if(i != -1)
    {
        Text = (Text $ Left(Input, i)) $ With;
        Input = Mid(Input, i + Len(Replace));
        i = InStr(Input, Replace);
        // [Loop Continue]
        goto J0x25;
    }
    Text = Text $ Input;
    //return;    
}

defaultproperties
{
    LimitOneText="Found active gravity vortex, vortex launcher disabled."
    LimitMoreText="Limit of %n active gravity vortices reached."
    LimitActiveText="Vortex launcher is temporarily disabled."
    bIsUnique=true
    bIsConsoleMessage=false
    bFadeMessage=true
    DrawColor=(R=200,G=200,B=0,A=255)
    StackMode=2
    PosY=0.30
    FontSize=1
}