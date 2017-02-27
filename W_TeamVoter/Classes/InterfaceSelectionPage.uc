//-----------------------------------------------------------
//
//-----------------------------------------------------------
class InterfaceSelectionPage extends PopupPageBase;

var automated GUISectionBackground          sb_RedMain, sb_BlueMain, sb_GreyMain, sb_RedCaptain, sb_BlueCaptain;
var automated GUIListBox                    lb_RedTeam, lb_BlueTeam, lb_GreyTeam, lb_RedCapt, lb_BlueCapt;
//var automated GUIMultiOptionListBox       lb_RedTeam, lb_BlueTeam, lb_GreyTeam, lb_RedCapt, lb_BlueCapt;
//var           GUIMultiOptionList          li_RedTeam, li_BlueTeam, li_GreyTeam;
var automated GUIHeader t_WindowTitleX;
var automated GUIButton b_Select;
var automated GUILabel l_Team,l_BlueTeam,l_RedTeam,l_MapName;
var automated moEditBox eb_Say;


//var bool bRedTeamSelecting;
var WumpusTeamsReplicationInfo WTRI;
var bool isInited;
var int GreyCount;
var int RedCount;
var int BlueCount;
var string CaptainName;

var string ClientPlayerName;
var int PingTime, iCountDown;
var float lTeamLeftRed, lTeamLeftBlue;

var int myCaptainCode;
var int gCurrentCaptain;
var int gPickingStatus;
var int pickDelay;

var int glow;
var int glowDirection;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.Initcomponent(MyController, MyOwner);

    t_WindowTitleX.SetCaption("Team Captains");

    sb_RedMain.Caption = "Red Team";
    sb_RedMain.ManageComponent(lb_RedTeam);

    sb_BlueMain.Caption = "Blue Team";
    sb_BlueMain.ManageComponent(lb_BlueTeam);

    sb_GreyMain.Caption = "Players";
    sb_GreyMain.ManageComponent(lb_GreyTeam);

    lb_GreyTeam.List.OnDblClick = GreyTeamListDoubleClick;

    isInited = false;
    CaptainName = "";

    b_Select.bVisible = false;
    ClientPlayerName = PlayerOwner().PlayerReplicationInfo.PlayerName;
    ResetTimer();
    myCaptainCode = 2;

    glow = 255;
    glowDirection = -10;
}


simulated event HandleParameters(string Param1, string Param2){
    LoadReplicationInfo();
}

simulated function Timer(){
    LoadReplicationInfo();
    UpdatePing();
    Blink();
}

simulated function ResetTimer(){
    SetTimer(0.1,true);
}

function Blink(){
    if(pickDelay > 0 || iCountDown < 1) return;
    glow = glow + glowDirection;

    if(glow > 240){
        glow = 240;
        glowDirection = -10;
    }

    if(glow < 100){
        glow = 100;
        glowDirection = 10;
    }

    if(gCurrentCaptain ==0){
        l_Team.BackColor.R=glow;
        l_Team.BackColor.B=0;
        l_Team.WinLeft = lTeamLeftRed;
        l_RedTeam.BackColor.R=glow;
        l_BlueTeam.BackColor.B=128;
    }else{
        l_Team.BackColor.R=0;
        l_Team.BackColor.B=glow;
        l_Team.WinLeft = lTeamLeftBlue;
        l_RedTeam.BackColor.R=128;
        l_BlueTeam.BackColor.B=glow;
    }

}

simulated function LoadReplicationInfo(){

    foreach PlayerOwner().DynamicActors(class'WumpusTeamsReplicationInfo',WTRI)
    {
        //if(WTRI.GreyCount ==0) Controller.CloseMenu(true);

        if(!isInited){
            InitBlueCapt(WTRI.BlueCaptainName);
            InitRedCapt(WTRI.RedCaptainName);
            InitMapName(GetMapName());
            isInited = true;
        }

        if(WTRI != none && WTRI.PickingStatus == 1 && pickDelay < 0){
            iCountDown = WTRI.CountDown;
            if(iCountDown < 1){
                iCountDown = 0;
                l_Team.Caption = "Auto Picked";
                b_Select.bVisible = false;
                return;
            }

            UpdateGreyTeam(WTRI);
            UpdateRedTeam(WTRI);
            UpdateBlueTeam(WTRI);
            UpdateCaptainSelection(WTRI);
            DisplayCountDown(iCountDown);
        }

    }

}

simulated function DisplayCountDown(int CountDown){
    l_Team.Caption = ""@CountDown;
}

simulated function UpdatePing(){
    if(PingTime < 0){
        PingServer();
        PingTime = 50;
    }
    PingTime--;
    pickDelay--;
}

simulated function PingServer(){
    if(ClientPlayerName == "") return;
    Console(Controller.Master.Console).DelayedConsoleCommand("MUTATE " $ "WTPING=" $ ClientPlayerName);
}

simulated function UpdateCaptainSelection(WumpusTeamsReplicationInfo tempWTRI){
    if(tempWTRI == none) return;

    gCurrentCaptain = tempWTRI.CurrentCaptain;
    gPickingStatus = tempWTRI.PickingStatus;

    if(myCaptainCode == tempWTRI.CurrentCaptain){
        b_Select.bVisible = true;
    }else{
        b_Select.bVisible = false;
    }

    l_Team.bVisible = true;


    //Blink();


}

simulated function UpdateGreyTeam(WumpusTeamsReplicationInfo tempWTRI){
    local int i,j;
    if(tempWTRI.GreyCount == GreyCount) return;
    j=-1;
    while(j != tempWTRI.GreyCount){
        j = tempWTRI.GreyCount;
        lb_GreyTeam.List.Clear();
        for(i=0;i<tempWTRI.GreyCount;i++){
            lb_GreyTeam.List.Add(tempWTRI.GreyTeam[i]);
        }
    }
    GreyCount = j;
}

simulated function UpdateRedTeam(WumpusTeamsReplicationInfo tempWTRI){
    local int i,j;
    if(tempWTRI.RedCount == RedCount) return;
    j=-1;
    while(j != tempWTRI.RedCount){
        j = tempWTRI.RedCount;
        lb_RedTeam.List.Clear();
        for(i=0;i<tempWTRI.RedCount;i++){
            lb_RedTeam.List.Add(tempWTRI.RedTeam[i]);
        }
    }
    RedCount = j;
}

simulated function UpdateBlueTeam(WumpusTeamsReplicationInfo tempWTRI){
    local int i,j;
    if(tempWTRI.BlueCount == BlueCount) return;
    j=-1;
    while(j != tempWTRI.BlueCount){
        j = tempWTRI.BlueCount;
        lb_BlueTeam.List.Clear();
        for(i=0;i<tempWTRI.BlueCount;i++){
            lb_BlueTeam.List.Add(tempWTRI.BlueTeam[i]);
        }
    }
    BlueCount = j;
}


function InitRedCapt(String CaptainName){
    l_RedTeam.Caption = CaptainName;
    if(CaptainName == ClientPlayerName){
        myCaptainCode = 0;
    }
}
function InitBlueCapt(String CaptainName){
    l_BlueTeam.Caption = CaptainName;
    if(CaptainName == ClientPlayerName){
        myCaptainCode = 1;
    }
}
function InitMapName(String MapName){
    l_MapName.Caption = MapName;
}

function bool InternalSelectButtonClick(GUIComponent Sender)
{
    SelectPlayer();
    return true;
}

function bool GreyTeamListDoubleClick(GUIComponent Sender){
    SelectPlayer();
    return true;
}

function SelectPlayer(){
    local String SelectedPlayerName;

    if(!b_Select.bVisible) return;
    if(myCaptainCode != gCurrentCaptain) return;
    if(gPickingStatus == 0) return;

    SelectedPlayerName = lb_GreyTeam.List.Get();

    if(SelectedPlayerName == "") return;

    if(iCountDown>0){
        Console(Controller.Master.Console).ConsoleCommand("MUTATE " $ "WTSELECT=" $ myCaptainCode $ SelectedPlayerName);
    }
    SelectedPlayerName = "";
    b_Select.bVisible = false;
    l_Team.bVisible = false;
    pickDelay = 20;

    return;
}


function bool CheckMessage (out byte Key, out byte State, float Delta)
{
  local string sTemp;

  if ( (Key == 13) && (State == 1) )
  {
    sTemp = eb_Say.GetText();
    if ( sTemp != "" )
    {
        if(sTemp == "WTABORT"){
            EndVote();
            sTemp = "Voting Cancelled";
        }
        if(sTemp == "WTRESTART"){
            RestartVoting();
            sTemp = "Voting Reset";
        }
        if(sTemp == "WTAUTO"){
            AutoPick();
            sTemp = "Automatic Picking Enabled";
        }
        if(sTemp == "WTTRIM"){
            TeamTrim();
            sTemp = "Removing Players";
        }
        if(sTemp == "DEMOREC"){
            RecordClient();
            sTemp = PlayerOwner().PlayerReplicationInfo.PlayerName@" Client Recording Started";
        }
        if(sTemp == "WTDEMOREC"){
            RecordServer();
            sTemp = "Server Recording Started";
        }
        PlayerOwner().ConsoleCommand("Say " $ sTemp);
    }
    eb_Say.SetText("");

    return True;
  }
  return False;
}

function EndVote(){
    Console(Controller.Master.Console).ConsoleCommand("MUTATE " $ "WTENDVOTE");
}

function TeamTrim(){
    Console(Controller.Master.Console).ConsoleCommand("MUTATE " $ "WTTRIM");
}

function AutoPick(){
    Console(Controller.Master.Console).ConsoleCommand("MUTATE " $ "WTAUTO");
}

function RestartVoting(){
    Console(Controller.Master.Console).ConsoleCommand("MUTATE " $ "WTRESTART");
}

function RecordClient(){
    PlayerOwner().ConsoleCommand("Demorec " $ GetDateTime() $ "-" $ GetMapName());
}

function RecordServer(){
    Console(Controller.Master.Console).ConsoleCommand("MUTATE " $ "WTDEMOREC");
}

function string GetDateTime ()
{
  local string AbsoluteTime;
  local LevelInfo Level;

    Level = PlayerOwner().Level;

    AbsoluteTime = string(Level.Year);
    if ( Level.Month < 10 )
    {
      AbsoluteTime = AbsoluteTime $ ".0" $ string(Level.Month);
    } else {
      AbsoluteTime = AbsoluteTime $ "." $ string(Level.Month);
    }
    if ( Level.Day < 10 )
    {
      AbsoluteTime = AbsoluteTime $ ".0" $ string(Level.Day);
    } else {
      AbsoluteTime = AbsoluteTime $ "." $ string(Level.Day);
    }
    AbsoluteTime = AbsoluteTime $ " - ";

    if ( Level.Hour < 10 )
    {
     AbsoluteTime = AbsoluteTime $ "0" $ string(Level.Hour);
    } else {
     AbsoluteTime = AbsoluteTime $ string(Level.Hour);
    }
    if ( Level.Minute < 10 )
    {
     AbsoluteTime = AbsoluteTime $ ".0" $ string(Level.Minute);
    } else {
     AbsoluteTime = AbsoluteTime $ "." $ string(Level.Minute);
    }
    if ( Level.Second < 10 )
    {
     AbsoluteTime = AbsoluteTime $ ".0" $ string(Level.Second);
    } else {
     AbsoluteTime = AbsoluteTime $ "." $ string(Level.Second);
    }
    return AbsoluteTime;
}

function string GetMapName ()
{
  local string MapName;
  local int i;

  MapName = string(PlayerOwner().Level.Game);
  i = InStr(MapName,".");
  if ( i != -1 ){
    MapName = Left(MapName,i);
  }else{
    MapName = PlayerOwner().Level.Title;
  }

  return MapName;
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=RedInternalFrameImage
         WinTop=0.220000
         WinLeft=0.120000
         WinWidth=0.240000
         WinHeight=0.550000
         OnPreDraw=RedInternalFrameImage.InternalPreDraw
     End Object
     sb_RedMain=AltSectionBackground'W_TeamVoter.InterfaceSelectionPage.RedInternalFrameImage'

     Begin Object Class=AltSectionBackground Name=BlueInternalFrameImage
         WinTop=0.220000
         WinLeft=0.640000
         WinWidth=0.240000
         WinHeight=0.550000
         OnPreDraw=BlueInternalFrameImage.InternalPreDraw
     End Object
     sb_BlueMain=AltSectionBackground'W_TeamVoter.InterfaceSelectionPage.BlueInternalFrameImage'

     Begin Object Class=AltSectionBackground Name=GreyInternalFrameImage
         WinTop=0.220000
         WinLeft=0.380000
         WinWidth=0.240000
         WinHeight=0.550000
         OnPreDraw=GreyInternalFrameImage.InternalPreDraw
     End Object
     sb_GreyMain=AltSectionBackground'W_TeamVoter.InterfaceSelectionPage.GreyInternalFrameImage'

     Begin Object Class=GUIListBox Name=RedTeamList
         bVisibleWhenEmpty=True
         OnCreateComponent=RedTeamList.InternalOnCreateComponent
         WinTop=0.143333
         WinLeft=0.037500
         WinWidth=0.918753
         WinHeight=0.697502
         RenderWeight=0.900000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_RedTeam=GUIListBox'W_TeamVoter.InterfaceSelectionPage.RedTeamList'

     Begin Object Class=GUIListBox Name=BlueTeamList
         bVisibleWhenEmpty=True
         OnCreateComponent=BlueTeamList.InternalOnCreateComponent
         WinTop=0.143333
         WinLeft=0.037500
         WinWidth=0.918753
         WinHeight=0.697502
         RenderWeight=0.900000
         TabOrder=5
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_BlueTeam=GUIListBox'W_TeamVoter.InterfaceSelectionPage.BlueTeamList'

     Begin Object Class=GUIListBox Name=GreyTeamList
         bVisibleWhenEmpty=True
         OnCreateComponent=GreyTeamList.InternalOnCreateComponent
         WinTop=0.143333
         WinLeft=0.037500
         WinWidth=0.918753
         WinHeight=0.697502
         RenderWeight=0.900000
         TabOrder=3
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_GreyTeam=GUIListBox'W_TeamVoter.InterfaceSelectionPage.GreyTeamList'

     Begin Object Class=GUIHeader Name=TitleBar
         bUseTextHeight=True
         WinHeight=0.100000
         RenderWeight=0.900000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         bNeverFocus=False
     End Object
     t_WindowTitleX=GUIHeader'W_TeamVoter.InterfaceSelectionPage.TitleBar'

     Begin Object Class=GUIButton Name=SelectButton
         Caption="Select Player"
         bAutoShrink=False
         WinTop=0.100000
         WinLeft=0.350000
         WinWidth=0.240000
         TabOrder=100
         bBoundToParent=True
         OnClick=InterfaceSelectionPage.InternalSelectButtonClick
         OnKeyEvent=SelectButton.InternalOnKeyEvent
     End Object
     b_Select=GUIButton'W_TeamVoter.InterfaceSelectionPage.SelectButton'

     Begin Object Class=GUILabel Name=TestLabel
         Caption="Select"
         TextAlign=TXTA_Center
         TextColor=(B=244,G=237,R=253)
         bTransparent=False
         BackColor=(R=128)
         WinTop=0.100000
         WinLeft=0.055000
         WinWidth=0.240000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_Team=GUILabel'W_TeamVoter.InterfaceSelectionPage.TestLabel'

     Begin Object Class=GUILabel Name=TestLabelBlue
         Caption="Blue Team"
         TextAlign=TXTA_Center
         TextColor=(B=244,G=237,R=253)
         bTransparent=False
         BackColor=(B=128)
         WinTop=0.050000
         WinLeft=0.705000
         WinWidth=0.240000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_BlueTeam=GUILabel'W_TeamVoter.InterfaceSelectionPage.TestLabelBlue'

     Begin Object Class=GUILabel Name=TestLabelRed
         Caption="Red Team"
         TextAlign=TXTA_Center
         TextColor=(B=244,G=237,R=253)
         bTransparent=False
         BackColor=(R=128)
         WinTop=0.050000
         WinLeft=0.055000
         WinWidth=0.240000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_RedTeam=GUILabel'W_TeamVoter.InterfaceSelectionPage.TestLabelRed'

     Begin Object Class=GUILabel Name=TestLabelMap
         TextAlign=TXTA_Center
         TextColor=(B=244,G=237,R=253)
         WinTop=0.050000
         WinLeft=0.350000
         WinWidth=0.300000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_MapName=GUILabel'W_TeamVoter.InterfaceSelectionPage.TestLabelMap'

     Begin Object Class=moEditBox Name=TestEditBoxSay
         CaptionWidth=0.080000
         Caption="Say: "
         OnCreateComponent=TestEditBoxSay.InternalOnCreateComponent
         WinTop=0.800000
         WinLeft=0.150000
         WinWidth=0.700000
         WinHeight=0.040000
         OnKeyEvent=InterfaceSelectionPage.CheckMessage
     End Object
     eb_Say=moEditBox'W_TeamVoter.InterfaceSelectionPage.TestEditBoxSay'

     PingTime=5
     lTeamLeftRed=0.055000
     lTeamLeftBlue=0.705000
     WinTop=0.100000
     WinLeft=0.100000
     WinWidth=0.800000
     WinHeight=0.800000
     bAcceptsInput=False
}
