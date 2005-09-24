<!---
	$Id: application.cfm,v 1.1 2005/09/24 22:12:44 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer-m2/application.cfm,v $
	$State: Exp $
	$Log: application.cfm,v $
	Revision 1.1  2005/09/24 22:12:44  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/11 14:18:23  rossd
	fixed application name
	
	Revision 1.1  2005/02/11 02:05:43  rossd
	mach-ii split out into it's own folder
	
	
    Copyright (c) 2005 David Ross
--->

<cfapplication name="CFfeedviewer-M2" sessionmanagement="yes" sessiontimeout="#createtimespan(0,0,75,0)#" />
