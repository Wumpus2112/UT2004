class Teamspeak3Link extends TcpLink abstract;

var() name LogClassName;
var() int  ConversationAttach, ConversationState, ConversationServerSelect, ConversationLogin, ConversationQuery, ConversationAdHoc;
var() bool isDebug;
var() bool isTrace;

var() bool isBusy;
var bool   isSuccessful;

var string  ServerAddress;      // Address of the server to connect
var int     ServerPort;
var int     RemotePort;         // Port of the server to connect
var string  ClientName;
var string  ClientPassword;

var string  LF, tab;        // Line feed character
var string  buf;            // Recieve buffer (for when the recievedtext goes over 999 characters)


function SendRequest(){

    local string query;

    isBusy = true;

    switch(ConversationState){
        case ConversationServerSelect:
            if (isDebug) Log ("SendRequest-ConversationServerSelect: Begin", LogClassName);
            SendText("use port=" $ ServerPort);
            break;
        case ConversationLogin:
            if (isDebug) Log ("SendRequest-ConversationLogin: Begin", LogClassName);
            SendText("login " $ ClientName $ " " $ ClientPassword);
            break;
        case ConversationQuery:
            if (isDebug) Log ("SendRequest-ConversationQuery: Begin", LogClassName);
            query = GetQueryString();
            SendText(query);
            break;
        default:
            if (isDebug) Log ("SendRequest-default: Error unknown ConversationState", LogClassName);
    }
}

function ProcessResponse(string Text){


    switch(ConversationState){
        case ConversationAttach:
            if (isDebug) Log ("ProcessResponse-ConversationAttach: Begin", LogClassName);
            ConversationState=ConversationServerSelect;
            SendRequest();
            break;
        case ConversationServerSelect:
            if (isDebug) Log ("ProcessResponse-ConversationServerSelect: Begin", LogClassName);
            ConversationState=ConversationLogin;
            SendRequest();
            break;
        case ConversationLogin:
            if (isDebug) Log ("ProcessResponse-ConversationLogin: Begin", LogClassName);
            ConversationState=ConversationQuery;
            SendRequest();
            break;
        case ConversationQuery:
            if (isDebug) Log ("ProcessResponse-ConversationQuery: Begin", LogClassName);
            isSuccessful = ProcessQueryResult(Text);
            if(!isSuccessful) ResetConversation();
            isBusy = false;
            break;
        case ConversationAdHoc:
            if (isDebug) Log ("ProcessResponse-ConversationAdHoc: Begin", LogClassName);
            ProcessAdHocResult(Text);
            isBusy = false;
            break;
        default:
            if(InStr(Text,"id=770") < 0 && InStr(Text,"id=0") < 0){
                Log ("ProcessResponse-default: Error unknown ConversationState. Message Received: "$Text, LogClassName);
            }
            isBusy = false;
    }
}

function ResetConversation(){
    CloseConnection();
    StartConnection();
    ConversationState = ConversationAttach;
}

function bool ProcessQueryResult(string Text);
function bool ProcessAdHocResult(string Text);
function string GetQueryString();

function Initialise(string IP, int Port, int SuperPort, string type, string login, string password, optional bool debug)
{
    ServerAddress = IP;
    ServerPort = Port;
    RemotePort = SuperPort;
    ClientName = login;
    ClientPassword = password;
    isDebug = debug;

    LF = Chr(10); // Line feed char "\n"
    tab = Chr(9);

    isSuccessful = false;
    StartConnection();
}

// First function called (init of the TCP connection)
function StartConnection(){
    isBusy = true;
    buf = "";

    if (isDebug) Log ("StartConnection: Attempt to 'Resolve' Server Address", LogClassName);
    Resolve (ServerAddress);   // Resolve the address of the server
}

event Resolved(IpAddr Addr ){
    if (isDebug) Log ("Resolved: Attempt to 'Connect' to Server", LogClassName);
    Connect(Addr);
}

// If the IP was not resolved...
event ResolveFailed()
{
    if (isDebug) Log ("ResolveFailed: ERROR - Unable to 'Resolve' Server Address. Will not attempt server connection.", LogClassName);
}

// called from resolve event
function Connect(IpAddr Addr){

    Addr.Port = RemotePort;
    BindPort(); // In UnrealTournament, the CLIENT has to make a bind to create a socket! (Not as a classic TCP connection!!!)

    ReceiveMode = RMODE_Event;  // Incomming messages are triggering events, not using Manual Mode
    LinkMode = MODE_Text;       // We expect to receive texts (if we receive data)

    if (isDebug) Log ("Connect: Attempt to  'Open' a server connection.", LogClassName);
    Open(Addr);                 // Open the connection
    if (isDebug) Log ("Connect: Connected ["$Addr.Addr$":"$Addr.port$"]", LogClassName);
}



function bool CloseConnection(){
    if (isDebug) Log ("CloseConnection: Attempt to 'Close' Connection", LogClassName);
    return Close();
}

//-----------------------------------------------------------------------------
// natives.

// SendText: Sends text string.
// Appends a cr/lf if LinkMode=MODE_Line.  Returns number of bytes sent.
//native function int SendText( coerce string Str );
function int SendText (coerce string Str)
{
    local int result;

    result = Super.SendText (Str$LF);  // Call the super (send the text)
    if(isDebug) Log ("SendText: ["$Str$"] length: "$result, LogClassName);

    return result;
}

// ReadText: Reads text string.
// Returns number of bytes read.
//native function int ReadText( out string Str );
function int ReadText (out string Str)
{
    local int result;

    result = Super.ReadText (Str);  // Call the super (read the text)
    if(isDebug) Log ("ReceivedLine: ["$Str$"] - ERROR Unexpected Method call. Using events for reading text. Change receive mode. See 'InternetInfo' class", LogClassName);

    return result;
}

//-----------------------------------------------------------------------------
// Events.

// Accepted: Called during STATE_Listening when a new connection is accepted.
event Accepted(){
      if(isDebug) Log ("Accepted", LogClassName);
}


// Opened: Called when socket successfully connects.
event Opened(){
    if(isDebug) Log ("Opened", LogClassName);
}

// Closed: Called when Close() completes or the connection is dropped.
event Closed(){
    if(isDebug) Log ("Closed", LogClassName);
}

// ReceivedText: Called when data is received and connection mode is MODE_Text.
event ReceivedText( string Text ){
     if(isTrace) Log ("ReceivedText: ["$Text$"]", LogClassName);
     Text = TrimText(Text);
     if(isTrace) Log ("ReceivedText-Trim: ["$Text$"]", LogClassName);
     ProcessResponse(Text);
}

function string TrimText(string Text){
    local int lineFeedIndex;
    lineFeedIndex = InStr(Text, LF);
    if(lineFeedIndex<0){
        return Text;
    }
    return Left(Text,lineFeedIndex);
}


// ReceivedLine: Called when data is received and connection mode is MODE_Line.
// \r\n is stripped from the line
event ReceivedLine( string Line ){
      if(isDebug) Log ("ReceivedLine: ["$Line$"] - ERROR Unexpected Receive line. Change 'LinkMode' to 'MODE_Text'.", LogClassName);
}

defaultproperties
{
     LogClassName="Teamspeak3Link"
     ConversationServerSelect=1
     ConversationLogin=2
     ConversationQuery=3
     ConversationAdHoc=4
}
