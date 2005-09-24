<!---
	$Id: index.cfm,v 1.1 2005/09/24 22:12:44 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer-m2/index.cfm,v $
	$State: Exp $
	$Log: index.cfm,v $
	Revision 1.1  2005/09/24 22:12:44  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/11 02:05:43  rossd
	mach-ii split out into it's own folder
	

    Copyright (c) 2005 David Ross
--->

<cfset request.MachIIConfigMode =iif(isDefined("url.rl"),1,0)/>
<cfset MACHII_CONFIG_PATH =ExpandPath('./controller/app-config.xml') />


<cfinclude template="/machii/mach-ii.cfm"/>