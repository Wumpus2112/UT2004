class HUDRadarSniper extends HudCTeamDeathMatch;

var()   SpriteWidget        TopRadarBG,EnemyRadarWidget;
var()   SpriteWidget        RadarWidget[10];


var()   SpriteWidget        CenterRadarBG;
var()   color               RedColorHUD;
var()   color               BlueColorHUD;
var()   Color               CurrentMutantColor;

var()   localized String    CamperRangeFontName;
var()   localized String    CamperRangeNorthFontName;

var()   Font                CamperRangeFontFont;
var()   Font                CamperRangeNorthFont;

var()   float               BigDotSize;
var()   float               SmallDotSize;

var()   float               BFIOriginX, BFIOriginY, BFISizeX, BFISizeY, BFIMargin, BFIPulseRate;

var()   Material            CommanderLeftIcon;
var()   Material            CommanderRightIcon;

var()   float               XCen, XRad, YCen, YRad; // Center radar tweaking
var()   float               MNOriginX, MNOriginY, MNSizeX, MNSizeY;
var()   float               RangeRampRegion;
var()   float               MaxAngleDelta;
var()   Color               RangeDotColor;
var()   float               HudDistance;

var()   vector              north, south, east, west;
var()   int                 MaxCommanderPlayers;


simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'InterfaceContent.HUD.SkinA');
    Super.UpdatePrecacheMaterials();
}


simulated function font LoadCommanderRangeFont()
{
    if( CamperRangeFontFont == None )
    {
        CamperRangeFontFont = Font(DynamicLoadObject(CamperRangeFontName, class'Font'));
        if( CamperRangeFontFont == None )
            Log("Warning: "$Self$" Couldn't dynamically load font "$CamperRangeFontName);
    }
    return CamperRangeFontFont;
}

simulated function font LoadCommanderNorthFont()
{
    if( CamperRangeNorthFont == None )
    {
        CamperRangeNorthFont = Font(DynamicLoadObject(CamperRangeNorthFontName, class'Font'));
        if( CamperRangeNorthFont == None )
            Log("Warning: "$Self$" Couldn't dynamically load font "$CamperRangeNorthFontName);
    }
    return CamperRangeNorthFont;
}

simulated function DrawHudPassA(Canvas C){
    DrawHudX(C);
}

simulated function DrawRadar(Canvas C, Pawn PawnOwner, string targetName, vector targetLocation, int playerNumber){
    local rotator Dir;
    local float Angle, VertDiff, Range;
    local float xCenter, yCenter;

    yCenter = 0.11*playerNumber-0.01;
    xCenter = 0.035;

    DrawSpriteWidget(C, RadarWidget[playerNumber]);

    Dir = rotator(targetLocation - PawnOwner.Location);
    VertDiff = targetLocation.Z - PawnOwner.Location.Z;

    Range = VSize(targetLocation - PawnOwner.Location) - (2 * class'xPawn'.default.CollisionRadius);
    Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;

    C.DrawColor = WhiteColor;

    C.Style = ERenderStyle.STY_Alpha;

    // radar blip
    C.SetPos((xCenter-0.008) * C.ClipX + HudScale * 0.034 * C.ClipX * sin(Angle),
        (yCenter+0.030) * C.ClipY - HudScale * 0.045 * C.ClipY * cos(Angle));

    // HUD
    C.DrawTile(Material'InterfaceContent.Hud.SkinA', BigDotSize*C.ClipX, BigDotSize*C.ClipX,838,238,144,144);
    C.Font = LoadCommanderRangeFont();
    C.DrawColor = WhiteColor;

    C.DrawTextJustified(targetName, 1, (xCenter-0.2) * C.ClipX, (yCenter + 0.005) * C.ClipY, (xCenter+0.2) * C.ClipX, (yCenter+ 0.055) * C.ClipY);
    C.DrawTextJustified( Min(int(Range),9999) , 1, (xCenter-0.1) * C.ClipX, (yCenter + 0.020) * C.ClipY, (xCenter+0.1) * C.ClipX, (yCenter+ 0.070) * C.ClipY);
    C.DrawTextJustified(Min(int(VertDiff),9999), 1, (xCenter-0.1) * C.ClipX, (yCenter+ 0.035) * C.ClipY, (xCenter+0.1) * C.ClipX, (yCenter+ 0.085) * C.ClipY);

}

simulated function DrawHudX(Canvas C)
{
    local rotator Dir;
    local float Angle, VertDiff, Range;
    local WumpusRadarSniperGameReplicationInfo radarGRI;
    local xWumpusRadarPawn  x;
    local bool bTestHud;
    local int i;
    local float distance;

    local float xCenter, yCenter;

    local int theTeamIndex;
    local string pName;

    yCenter = 0.11;
    xCenter = 0.5;

    bTestHud = false;

    Super.DrawHudPassA (C);

    radarGRI = WumpusRadarSniperGameReplicationInfo(PlayerOwner.GameReplicationInfo);
    x = xWumpusRadarPawn(PawnOwner);

    // commander radar - start

        // Draw radar outline
        PassStyle=STY_None;
        DrawSpriteWidget (C, CenterRadarBG);
        PassStyle=STY_Alpha;

        // Draw Height Line
        /*
        C.Style = ERenderStyle.STY_Alpha;
        C.DrawColor = WhiteColor;
        C.SetPos(XCen * C.ClipX * 0.1, YCen * C.ClipY - 400 );
        C.DrawLine(1,800);
        */
        pName = PlayerOwner.PlayerReplicationInfo.PlayerName;
        theTeamIndex = PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;

        // draw red team
        for(i=0;i<MaxCommanderPlayers;i++)
        {




            if(radarGRI.PlayerName[i] != "-")
            {


                if( (theTeamIndex != radarGRI.PlayerTeam[i])/*  || theTeamIndex == 0 */){
                    // don't want to see myself
                    if(radarGRI.PlayerName[i] != pName){
                        // "-" is an empty slot
                        Dir = rotator(radarGRI.PlayerLocation[i] - PawnOwner.Location);
                        Range = VSize(radarGRI.PlayerLocation[i] - PawnOwner.Location) - (2 * class'xPawn'.default.CollisionRadius);
                        Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;

                        C.DrawColor = RedColor;
                        C.Style = ERenderStyle.STY_Alpha;

                        // center radar
                        distance = HudScale * (Range-abs(VertDiff)+1.0)/HudDistance;
                        if(distance > HudScale*2) distance = HudScale*2;
                        C.SetPos(XCen * C.ClipX + distance * XRad * C.ClipX * sin(Angle) - 0.5*BigDotSize*C.ClipX, YCen * C.ClipY - distance * YRad * C.ClipY * cos(Angle) - 0.5*BigDotSize*C.ClipX );
                        C.DrawTile(Material'InterfaceContent.Hud.SkinA', BigDotSize*C.ClipX, BigDotSize*C.ClipX,838,238,144,144);

                        C.DrawColor = WhiteColor;
                        C.Style = ERenderStyle.STY_Alpha;
                        C.Font = LoadCommanderRangeFont();
                        C.SetPos(XCen * C.ClipX + distance * XRad * C.ClipX * sin(Angle) - 0.5*BigDotSize*C.ClipX, YCen * C.ClipY - distance * YRad * C.ClipY * cos(Angle) - 0.5*BigDotSize*C.ClipX );
                        C.DrawText(radarGRI.PlayerName[i]);
                    }
                }
            }
        }



        // **** Draw "North" - start ****
        VertDiff = 0;
        Range = 9999999;

        C.DrawColor = WhiteColor;
        C.Style = ERenderStyle.STY_Alpha;
        C.Font = LoadCommanderNorthFont();

        // center radar
        distance = HudScale*2;

        // north
        Dir = rotator(north - PawnOwner.Location);
        Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
        C.SetPos(XCen * C.ClipX + distance * XRad * C.ClipX * sin(Angle) - 0.5*BigDotSize*C.ClipX, YCen * C.ClipY - distance * YRad * C.ClipY * cos(Angle) - 0.5*BigDotSize*C.ClipX );
        C.DrawText("N");


        // south
        Dir = rotator(south - PawnOwner.Location);
        Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
        C.SetPos(XCen * C.ClipX + distance * XRad * C.ClipX * sin(Angle) - 0.5*BigDotSize*C.ClipX, YCen * C.ClipY - distance * YRad * C.ClipY * cos(Angle) - 0.5*BigDotSize*C.ClipX );
        C.DrawText("S");


        // east
        Dir = rotator(east - PawnOwner.Location);
        Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
        C.SetPos(XCen * C.ClipX + distance * XRad * C.ClipX * sin(Angle) - 0.5*BigDotSize*C.ClipX, YCen * C.ClipY - distance * YRad * C.ClipY * cos(Angle) - 0.5*BigDotSize*C.ClipX );
        C.DrawText("E");


        // west
        Dir = rotator(west - PawnOwner.Location);
        Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
        C.SetPos(XCen * C.ClipX + distance * XRad * C.ClipX * sin(Angle) - 0.5*BigDotSize*C.ClipX, YCen * C.ClipY - distance * YRad * C.ClipY * cos(Angle) - 0.5*BigDotSize*C.ClipX );
        C.DrawText("W");

        // **** Draw "North" - end ****


}

defaultproperties
{
     TopRadarBG=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.500000,PosY=0.010000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     EnemyRadarWidget=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.500000,PosY=0.120000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RadarWidget(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.035000,PosY=0.100000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RadarWidget(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.035000,PosY=0.210000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RadarWidget(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.035000,PosY=0.320000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RadarWidget(4)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.035000,PosY=0.430000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RadarWidget(5)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.035000,PosY=0.540000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RadarWidget(6)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.035000,PosY=0.650000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RadarWidget(7)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.035000,PosY=0.760000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CenterRadarBG=(WidgetTexture=Texture'MutantSkins.HUD.big_circle',RenderStyle=STY_Translucent,TextureCoords=(X1=255,Y2=255),TextureScale=1.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RedColorHUD=(R=255,A=255)
     BlueColorHUD=(B=255,A=255)
     CurrentMutantColor=(B=128,R=255,A=255)
     CamperRangeFontName="UT2003Fonts.FontMono"
     CamperRangeNorthFontName="UT2003Fonts.FontLarge"
     BigDotSize=0.018750
     SmallDotSize=0.011250
     BFIOriginX=0.350000
     BFIOriginY=0.100000
     BFISizeX=0.300000
     BFISizeY=0.050000
     BFIMargin=0.010000
     BFIPulseRate=1.000000
     CommanderLeftIcon=Texture'2K4Menus.Controls.dblarrowLeft_b'
     CommanderRightIcon=Texture'2K4Menus.Controls.dblarrowRight_b'
     XCen=0.500000
     XRad=0.150000
     YCen=0.500000
     YRad=0.200000
     MNOriginX=0.280000
     MNOriginY=0.008000
     MNSizeX=0.450000
     MNSizeY=0.060000
     RangeRampRegion=2500.000000
     MaxAngleDelta=1.000000
     RangeDotColor=(B=50,G=200,R=200,A=255)
     HudDistance=5000.000000
     north=(X=9999999.000000)
     south=(X=-9999999.000000)
     east=(Y=9999999.000000)
     west=(Y=-9999999.000000)
     MaxCommanderPlayers=16
}
