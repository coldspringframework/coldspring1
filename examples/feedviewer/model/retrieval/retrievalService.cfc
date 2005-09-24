<!---
	$Id: retrievalService.cfc,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/retrieval/retrievalService.cfc,v $
	$State: Exp $
	$Log: retrievalService.cfc,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/07 21:57:40  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Abstract Retrieval Service" output="false">
	
	<cffunction name="init" access="private">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="retrieve" returntype="string" output="false" hint="Returns content for a remote url" access="public">
		<cfargument name="url" type="string" required="true" hint="url to be retrieved"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
</cfcomponent>