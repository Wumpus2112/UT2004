class Teamspeak3LinkChannel extends Teamspeak3Link;

struct TSChannelInfo
{
    var string ChannelId;
    var string ChannelName;
};
var TSChannelInfo TSChannel[10];
var int           NumChannels;

function string GetChannelIdByName (String ChannelName)
{
    local int i;
    for(i=0;i<NumChannels;i++){
        if(ChannelName == TSChannel[i].ChannelName) return TSChannel[i].ChannelId;
    }
    return "-1";
}

function bool ProcessQueryResult(string Text){
    local array<string> ChannelText,ChannelProperty,PropertyValuePairs;
    local int i,j;
    local int ChannelTextSize,ChannelPropertySize,PropertyValuePairSize;
    local string PropertyName, PropertyValue;

    if (isDebug) Log ("ProcessQueryResult: " $ Text, LogClassName);

    ChannelTextSize=Split(Text,"|",ChannelText);
    NumChannels=ChannelTextSize;

    if (isDebug) Log("ProcessQueryResult: NumberOf Channels: " $string(ChannelText.Length));
    if(ChannelText.Length < 2){
        Log("ProcessQueryResult: ERROR! NumberOf Channels: " $string(ChannelText.Length));
        //return false;
    }

    for(i=0 ; i < ChannelTextSize ; i++)
	{
	    if (isDebug) Log ("ChannelText [" $ChannelText[i]$ "]", LogClassName);

		ChannelPropertySize=Split(ChannelText[i]," ",ChannelProperty);
        for(j=0;j<ChannelPropertySize;j++)
	    {
	        if (isTrace) Log ("ChannelProperty [" $ChannelProperty[j]$ "]", LogClassName);

            PropertyValuePairSize=Split(ChannelProperty[j],"=",PropertyValuePairs);

            if(PropertyValuePairs.Length>1){
                PropertyName=PropertyValuePairs[0];
                PropertyValue=PropertyValuePairs[1];
            }

		    if(PropertyName == "cid"){
		        TSChannel[i].ChannelId = PropertyValue;
                if (isDebug) Log ("ChannelId: " $ TSChannel[i].ChannelId, LogClassName);
		    }

		    if(PropertyName == "channel_name"){
		        TSChannel[i].ChannelName = PropertyValue;
                if (isDebug) Log ("ChannelName: " $ TSChannel[i].ChannelName, LogClassName);
		    }

		}

	}

	return true;
}

function string GetQueryString(){
    return "channellist";
}

defaultproperties
{
     LogClassName="Teamspeak3LinkChannel"
}
