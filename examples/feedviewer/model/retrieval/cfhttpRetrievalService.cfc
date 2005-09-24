<!---
	$Id: cfhttpRetrievalService.cfc,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/retrieval/cfhttpRetrievalService.cfc,v $
	$State: Exp $
	$Log: cfhttpRetrievalService.cfc,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/08 21:31:18  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:40  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="cfhttp Retrieval Service" extends="coldspring.examples.feedviewer.model.retrieval.retrievalService" output="false">
	
	<cffunction name="init" access="public" output="false" returntype="coldspring.examples.feedviewer.model.retrieval.cfhttpRetrievalService">
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="retrieve" returntype="string" output="false" hint="Returns content contained in a remote url" access="public">
		<cfargument name="url" type="string" required="true" hint="url to be retrieved"/>
		<cfset var cfhttp = structnew()/>
		<!--- we may end up having to lock here --->
		<cfhttp method="get" url="#arguments.url#" />
		<cfreturn cfhttp.FileContent/>
	</cffunction>
	
</cfcomponent>