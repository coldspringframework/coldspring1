<!---
	$Id: dspCategory.cfm,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/view/html/dspCategory.cfm,v $
	$State: Exp $
	$Log: dspCategory.cfm,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.5  2005/05/11 01:28:36  jared_cmg
	Fixes in to fusebox examples:
	error in CFC type in eventArgs.cfm
	error in /examples/feedviewer/view/Channel.cfm
	
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

<cfset Category = event.getArg('category')/>
<cfoutput>
<form action="index.cfm?event=c.SaveCategory" method="post">
<table id="catSingleTable" cellpadding="3" cellspacing="0" align="center">
<cfif Category.hasId()>
	<input type="hidden" name="id" value="#Category.getId()#"/>
</cfif>

<tr><td class="catTitle">Category:</td><td colspan="2">&nbsp;</td></tr>
<tr><td>Name:</td><td><input type="text" name="name" value="#Category.getName()#" size="55"/></td>

<td width="200" rowspan="3" class="CategoryChannelHeader">	
<cfif event.isArgDefined('categorychannels')>
	<cfset CategoryChannels = event.getArg('categorychannels')/>
	Channels:<br />
	<ul>
		<cfloop query="CategoryChannels">
			<li <cfif currentrow mod 2>class="hl"</cfif>><a href="index.cfm?event=c.showChannel&amp;channelID=#id#">#title#</a></li>
		</cfloop>
	</ul> 
</cfif>
</td>
</tr>
<tr><td>Description:</td><td><input type="text" name="description" value="#Category.getDescription()#" size="55"/></td></tr>
<tr><td colspan="2" align="center" valign="top">
	<input type="submit" value="<cfif Category.hasId()>save<cfelse>create</cfif>" class="subbtn"/>&nbsp;&nbsp;
	<input type="button" onclick="javascript: self.location.href='index.cfm'" value="cancel" class="subbtn"/>&nbsp;&nbsp;  
	<cfif Category.hasId()><input type="button" onclick="javascript: if(confirm('Click OK if you are sure you want to remove this category'))self.location.href='index.cfm?event=c.removeCategory&amp;categoryID=#category.getId()#'" value="remove" class="rembtn"/></cfif></td></tr>
</table>
</form>
</cfoutput>