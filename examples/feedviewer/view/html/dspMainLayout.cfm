<!---
	$Id: dspMainLayout.cfm,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/view/html/dspMainLayout.cfm,v $
	$State: Exp $
	$Log: dspMainLayout.cfm,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.4  2005/02/11 02:16:27  rossd
	*** empty log message ***
	
	Revision 1.3  2005/02/10 16:40:09  rossd
	naming convention change to support view re-use in fb4 example
	
	Revision 1.2  2005/02/08 21:31:18  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:40  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfoutput>
<html>
<head>
	<title>CFML stupid feedviewer, v#getProperty('applicationVersion')#</title>
	<link rel="stylesheet" type="text/css" href="#getProperty('styleSheetPath')#" />

</head>

<body>
<table id="mainTable" width="100%">
	
	<cfif event.isArgDefined('headerContent')>
		<tr><td colspan="2" class="mainHeader">#event.getArg('headerContent')#</td></tr>
	</cfif>
		
	<tr>
	
	<td width="25%" class="leftContent" valign="top"><cfif structKeyExists(request,'leftColContent')>#request.leftColContent#</cfif></td>
	<td class="mainContent" width="75%" valign="top">
	<cfif event.isArgDefined("message")><div id="message">#event.getArg('message')#</div></cfif>
	<cfif structKeyExists(request,'mainContent')>#request.mainContent#</cfif>
	
	</td></tr>
	
	<cfif event.isArgDefined('footerContent')>
		<tr><td colspan="2" class="mainFooter">#event.getArg('footerContent')#</td></tr>
	</cfif>
</table>
</cfoutput>
</body>
</html>
