<!---
	$Id: dspChannel.cfm,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/view/html/dspChannel.cfm,v $
	$State: Exp $
	$Log: dspChannel.cfm,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.4  2005/02/10 16:40:09  rossd
	naming convention change to support view re-use in fb4 example
	
	Revision 1.3  2005/02/09 14:40:09  rossd
	*** empty log message ***
	
	Revision 1.2  2005/02/08 21:31:18  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:40  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->


<cfset channel = event.getArg('channel')/>
<cfset categories = event.getArg('categories')/>

<cfoutput>
<form action="index.cfm?event=c.saveChannel" method="post">
<table id="catSingleTable" cellpadding="3" cellspacing="0" align="center">
<cfif channel.hasId()>
	<input type="hidden" name="id" value="#channel.getId()#"/>
</cfif>
<tr><td valign="top">
<table>


<tr><td class="catTitle">Channel:</td><td colspan="2">&nbsp;</td></tr>
<tr><td>Title:</td><td><input type="text" name="title" value="#channel.getTitle()#" size="60"/></td>
<tr><td>RSS/Atom Url:</td><td><input type="text" name="url" value="#channel.getUrl()#" size="60"/></td>
<tr><td>Description:</td><td><input type="text" name="description" value="#channel.getDescription()#" size="60"/></td></tr>
<tr><td>Category(s):</td><td><select name="categoryIDs" multiple size="4">
								<cfloop query="categories">
								<option value="#id#" <cfif listFind(channel.getCategoryIds(),id)>selected</cfif>>#name#</option>
								</cfloop>
							</select></td></tr>
<tr>
	<td colspan="2" align="center" valign="top" nowrap>
		<input type="submit" value="<cfif channel.hasId()>save<cfelse>create</cfif>" class="subbtn"/>&nbsp;&nbsp;
		<input type="button" onclick="javascript: self.location.href='index.cfm'" value="cancel" class="subbtn"/>&nbsp;&nbsp;  
		<cfif channel.hasId()>
			<input type="button" onclick="javascript: self.location.href='index.cfm?event=c.refreshChannelEntries&amp;channelID=#channel.getId()#'" value="refresh entries" class="subbtn"/>
			&nbsp;&nbsp;<input type="button" onclick="javascript: if(confirm('Click OK if you are sure you want to remove this channel'))self.location.href='index.cfm?event=c.removechannel&amp;channelID=#channel.getId()#'" value="remove" class="rembtn"/>
		</cfif>
	</td>
</tr>

</table>
</td>
<td valign="top" class="CategoryChannelHeader">	
<cfif event.isArgDefined('channelentries')>
	<cfset channelEntries = event.getArg('channelentries')/>
	Recent Entries:<br />
	<ul>
		<cfloop query="channelEntries">
			<li <cfif currentrow mod 2>class="hl"</cfif>><a href="#url#" target="_blank">#title#</a></li>
		</cfloop>
	</ul> 
</cfif>
</td>
</tr>
</table>
</form>
</cfoutput>