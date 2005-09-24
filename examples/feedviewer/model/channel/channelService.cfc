<!---
	$Id: channelService.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/channel/channelService.cfc,v $
	$State: Exp $
	$Log: channelService.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.3  2005/02/09 15:07:08  rossd
	*** empty log message ***
	
	Revision 1.2  2005/02/08 21:31:17  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:39  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Channel Service" output="false">

	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer.model.channel.channelService" output="false">
	
		<cfreturn this/>
	
	</cffunction>

	<cffunction name="setChannelDAO" returntype="void" access="public"	output="false" hint="dependency: channelDAO">
		<cfargument name="channelDAO" type="coldspring.examples.feedviewer.model.channel.channelDAO"	required="true"/>
		
		<cfset variables.m_channelDAO = arguments.channelDAO/>
			
	</cffunction>	

	<cffunction name="setChannelGateway" returntype="void" access="public" output="false" hint="dependency: channelGateway">
		<cfargument name="channelGateway" type="coldspring.examples.feedviewer.model.channel.channelGateway" required="true"/>
		
		<cfset variables.m_channelGateway = arguments.channelGateway/>
			
	</cffunction>
	
	<cffunction name="getAll" returntype="query" access="public" output="false" hint="I retrieve all existing categories">
		<cfreturn variables.m_channelGateway.getAll()/>
	</cffunction>

	<cffunction name="getById" returntype="coldspring.examples.feedviewer.model.channel.channel" access="public" output="false" hint="I retrieve a channel by id">
		<cfargument name="channelId" type="numeric" required="true" hint="id of channel to get"/>
		<cfreturn variables.m_channelDAO.fetch(arguments.channelId)/>
	</cffunction>
	
	<cffunction name="save" returntype="void" access="public" output="false" hint="I save a channel">
		<cfargument name="channel" type="coldspring.examples.feedviewer.model.channel.channel" required="true" hint="channel to save"/>
		<cfreturn variables.m_channelDAO.save(arguments.channel)/>
	</cffunction>	
	
	<cffunction name="remove" returntype="void" access="public" output="false" hint="I remove a channel">
		<cfargument name="channel" type="coldspring.examples.feedviewer.model.channel.channel" required="true" hint="channel to remove"/>
		<cfreturn variables.m_channelDAO.remove(arguments.channel)/>
	</cffunction>	

	<cffunction name="getAllByCategory" returntype="query" output="false" hint="I retrieve all existing channels by category id" access="public">
		<cfargument name="catIds" type="array" required="true" hint="array of Ids of the categories restrict to"/>
		<cfreturn variables.m_channelGateway.getAllByCategories(arguments.catIds)/>
	</cffunction>
	
</cfcomponent>