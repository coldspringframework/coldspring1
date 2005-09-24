<!---
	$Id: channelGateway.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/channel/channelGateway.cfc,v $
	$State: Exp $
	$Log: channelGateway.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/07 21:57:39  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Abstract Channel Gateway" output="false">
	
	<cffunction name="init" access="private">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="getAll" returntype="query" output="false" hint="I retrieve all existing channels" access="public">
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
	<cffunction name="getAllByCategories" returntype="query" output="false" hint="I retrieve all existing channels by channelID" access="public">
		<cfargument name="channelIds" type="array" required="true" hint="array of Ids of the categories restrict to"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>	
	
</cfcomponent>