class GlitchMessages extends LocalMessage;

var localized string          sGlitchFast;
var localized string          sGlitchSlow;
var localized string          sGlitchCombo;
var localized string          sGlitchWeapons;
var localized string          sGlitchNoWeapons;
var localized string          sGlitchPort;
var localized string          sGlitchVis;
var localized string          sGlitchMove;
var localized string          sGlitchGrav;
var localized string          sGlitchFly;
var localized string          sGlitchSpider;

var localized string          sGlitchInvis;
var localized string          sGlitchMini;
var localized string          sGlitchCamo;
var localized string          sGlitchHealth;
var localized string          sGlitchHead;


var localized string          sGlitchUnknown;

var int         GlitchFast;
var int         GlitchSlow;
var int         GlitchWeapons;
var int         GlitchNoWeapons;
var int         GlitchPort;
var int         GlitchVis;
var int         GlitchMove;
var int         GlitchGrav;
var int         GlitchFly;
var int         GlitchSpider;
var int         GlitchInvis;
var int         GlitchMini;
var int         GlitchCamo;
var int         GlitchHealth;
var int         GlitchHead;


static function string GetString(
    optional int msgNumber,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch(msgNumber){
        case default.GlitchFast:
             return default.sGlitchFast;
        case default.GlitchSlow:
             return default.sGlitchSlow;
        case default.GlitchWeapons:
             return default.sGlitchWeapons;
        case default.GlitchNoWeapons:
             return default.sGlitchNoWeapons;
        case default.GlitchPort:
             return default.sGlitchPort;
        case default.GlitchVis:
             return default.sGlitchVis;
        case default.GlitchMove:
             return default.sGlitchMove;
        case default.GlitchGrav:
             return default.sGlitchGrav;
        case default.GlitchFly:
             return default.sGlitchFly;
        case default.GlitchSpider:
             return default.sGlitchSpider;
        case default.GlitchInvis:
             return default.sGlitchInvis;
        case default.GlitchMini:
             return default.sGlitchMini;
        case default.GlitchCamo:
             return default.sGlitchCamo;
        case default.GlitchHealth:
             return default.sGlitchHealth;
        case default.GlitchHead:
             return default.sGlitchHead;

        default:
    }
    return default.sGlitchUnknown;
}

defaultproperties
{
sGlitchFast="Overclocking"
sGlitchSlow="Bullet Time"
sGlitchWeapons="OH MY GOD!!!"
sGlitchNoWeapons="No Ammo"
sGlitchPort="Respawn"
sGlitchVis=">>> Nausea <<<"
sGlitchMove="Lag!!!!"
sGlitchGrav="Low Grav"
sGlitchFly="Spread your wings"
sGlitchSpider="Wall Crawler"

sGlitchInvis="Ghosts 'n Stuff"
sGlitchMini="Everything looks bigger"
sGlitchCamo="Polymorph"
sGlitchHealth="Regeneration"
sGlitchHead="Head Rush"

sGlitchUnknown="- Welcome to Glitch Mod -"

    GlitchFly=0
    GlitchVis=1
    GlitchGrav=2
    GlitchMove=3
    GlitchSpider=4
    GlitchFast=5
    GlitchSlow=6
    GlitchWeapons=7
    GlitchNoWeapons=8
    GlitchPort=9

    GlitchInvis=10
    GlitchMini=11
    GlitchCamo=12
    GlitchHealth=13

     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(R=255,B=128,G=0)
     StackMode=SM_Down
     PosY=0.100000
}
