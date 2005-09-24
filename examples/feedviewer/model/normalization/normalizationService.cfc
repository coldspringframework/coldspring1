<!---
	$Id: normalizationService.cfc,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/normalization/normalizationService.cfc,v $
	$State: Exp $
	$Log: normalizationService.cfc,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/09 04:26:41  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:40  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Abstract Normalization Service" output="false">
	
	<cffunction name="init" access="private">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="normalize" returntype="array" output="false" hint="Returns an array of structs containing author, content, date, id, link, and title members. Also returns an isHtml member that is set to 'true' when the content element contains HTML." access="public">
		<cfargument name="url" type="string" required="true">
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
</cfcomponent>