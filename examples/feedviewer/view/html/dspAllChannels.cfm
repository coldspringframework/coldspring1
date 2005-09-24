<!---
	$Id: dspAllChannels.cfm,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/view/html/dspAllChannels.cfm,v $
	$State: Exp $
	$Log: dspAllChannels.cfm,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/10 16:40:09  rossd
	naming convention change to support view re-use in fb4 example
	
	Revision 1.1  2005/02/08 21:31:18  rossd
	*** empty log message ***
	

    Copyright (c) 2005 David Ross
--->

<cfset allChannels = event.getArg('channels')/>

<table id="catTable" width="98%" cellpadding="3" cellspacing="0">
<tr><td class="header">Channels:&nbsp;&nbsp;(<a href="index.cfm?event=c.newChannel">new</a>)</td></tr>
<cfoutput query="allChannels">
	<tr>
		<td <cfif event.getArg('channelID') eq id>class="selected"</cfif>><a href="index.cfm?event=c.showChannel&amp;channelId=#id#">#title#</a></td>
		</tr>
</cfoutput>
</table>
