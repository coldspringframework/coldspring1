<!---
	$Id: dspEntries.cfm,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/view/html/dspEntries.cfm,v $
	$State: Exp $
	$Log: dspEntries.cfm,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.3  2005/02/10 16:40:09  rossd
	naming convention change to support view re-use in fb4 example
	
	Revision 1.2  2005/02/09 04:26:41  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/08 21:31:18  rossd
	*** empty log message ***
	

    Copyright (c) 2005 David Ross
--->

<cfscript>
    /**
    * Removes HTML from the string.
    * 
    * @param string String to be modified. 
    * @return Returns a string. 
    * @author Raymond Camden (ray@camdenfamily.com) 
    * @version 1, December 19, 2001 
    */
    function StripHTML(str) {
                 return REReplaceNoCase(str,"<[^>]*>","","ALL");
    }
</cfscript>

<cfset entries = event.getArg('entries')/>
<cfoutput>
<table id="entriesTable" cellpadding="3" cellspacing="0" border="0">
	<cfloop query="entries">
	<tr>
		<td width="100%">
			<table class="singleEntry" border="0" width="100%">
				<tr><td class="entryTitle"><strong>#blogTitle#&nbsp;::&nbsp; <a href="#url#" target="_blank">#title#</a></strong></td>
				<td  class="entryTitle" align="right">#authored_on#</td>
				</tr>
				<tr><td colspan="2">#Left(StripHTML(body),450)#</td></tr>
			</table>
		</td>
	</tr>	
	</cfloop>
</table>
</cfoutput>

