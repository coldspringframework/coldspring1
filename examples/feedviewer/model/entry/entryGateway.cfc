<!---
	$Id: entryGateway.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/entry/entryGateway.cfc,v $
	$State: Exp $
	$Log: entryGateway.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/08 21:31:18  rossd
	*** empty log message ***
	
	
    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Abstract entry gateway" output="false">
	
	<cffunction name="init" access="private">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="getAll" returntype="query" output="false" access="public" hint="I retrieve a entry">
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>

	<cffunction name="getByChannelID" returntype="query" output="false" access="public" hint="I retrieve a entry">
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
	<cffunction name="getByCategoryID" returntype="query" output="false" access="public" hint="I retrieve a entry">
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
</cfcomponent>