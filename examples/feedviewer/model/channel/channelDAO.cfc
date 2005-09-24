<!---
	$Id: channelDAO.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/channel/channelDAO.cfc,v $
	$State: Exp $
	$Log: channelDAO.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/07 21:57:39  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Abstract channel DAO" output="false">
	
	<cffunction name="init" access="private">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="fetch" returntype="coldspring.examples.feedviewer.model.channel.channel" output="false" access="public" hint="I retrieve a channel">
		<cfargument name="channelIdentifier" type="any" required="true" hint="I am the unique ID of the channel to be retrieved"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>

	<cffunction name="save" returntype="void" output="false" access="public" hint="I save a channel">
		<cfargument name="channel" type="coldspring.examples.feedviewer.model.channel.channel" hint="I am the channel to be saved" required="true"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
	<cffunction name="remove" returntype="void" output="false" access="public" hint="I remove a channel">
		<cfargument name="channel" type="coldspring.examples.feedviewer.model.channel.channel" hint="I am the channel to be removed" required="true"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
</cfcomponent>