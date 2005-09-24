<!---
	$Id: dspAllCategories.cfm,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/view/html/dspAllCategories.cfm,v $
	$State: Exp $
	$Log: dspAllCategories.cfm,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.4  2005/02/14 00:12:37  rossd
	*** empty log message ***
	
	Revision 1.3  2005/02/10 16:40:09  rossd
	naming convention change to support view re-use in fb4 example
	
	Revision 1.2  2005/02/08 21:31:18  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:40  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfset allCats = event.getArg('categories')/>

<table id="catTable" width="98%" cellpadding="3" cellspacing="0">
<tr><td class="header" colspan="2">Categories:&nbsp;&nbsp;(<a href="index.cfm?event=c.newCategory">new</a>)</td></tr>
<cfoutput query="allCats">
	<tr>
		<td <cfif event.getArg('categoryID') eq id>class="selected"</cfif>><a href="index.cfm?event=c.showCategory&amp;categoryId=#id#">#name#</a></td>
		<td <cfif event.getArg('categoryID') eq id>class="selected"</cfif>><cfif len(Channelcount)>#Channelcount# Channel<cfif channelCount gt 1>s</cfif></cfif></td>
	</tr>
</cfoutput>
</table>
