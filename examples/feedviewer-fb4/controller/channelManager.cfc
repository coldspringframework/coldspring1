<!---
	$Id: channelManager.cfc,v 1.1 2005/09/24 22:12:43 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer-fb4/controller/channelManager.cfc,v $
	$State: Exp $
	$Log: channelManager.cfc,v $
	Revision 1.1  2005/09/24 22:12:43  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.3  2005/02/11 17:56:54  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	
	Revision 1.2  2005/02/10 16:40:18  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/10 13:07:22  rossd
	*** empty log message ***
	
    Copyright (c) 2005 David Ross
--->

<cfcomponent name="channelListener.cfc" output="false">
	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer-fb4.controller.channelManager" output="false">
		<cfargument name="serviceFactory" type="coldspring.beans.BeanFactory" required="yes"/>
		<cfset variables.m_channelService = arguments.serviceFactory.getBean('channelService')/>
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="getAllChannels" returntype="query" access="public" output="false" hint="I retrieve all existing categories">
		<cfreturn variables.m_channelService.getAll()/>
	</cffunction>
	
	<cffunction name="getChannelById" returntype="coldspring.examples.feedviewer.model.channel.channel" access="public" output="false" hint="I retrieve a channel">
		<cfargument name="event" type="coldspring.examples.feedviewer-fb4.plugins.event" required="yes" displayname="Event"/>
		<cfreturn variables.m_channelService.getById(arguments.event.getArg('channelId'))/>		
	</cffunction>	
	
	<cffunction name="getChannelsByCategoryId" access="public" returntype="query" output="false" hint="I retrieve a category">
		<cfargument name="event" type="coldspring.examples.feedviewer-fb4.plugins.event" required="yes" displayname="Event"/>
			
		<cfreturn variables.m_channelService.getAllByCategory(listToArray(arguments.event.getArg('categoryId')))/>
	
	</cffunction>
	
	<cffunction name="saveChannel" access="public" returntype="boolean" output="false" hint="I save a channel">
		<cfargument name="event" type="coldspring.examples.feedviewer-fb4.plugins.event" required="yes" displayname="Event"/>
		
		<cftry>
			<cfset variables.m_channelService.save(arguments.event.getArg('channel'))/>
			<cfcatch>
				<cfset arguments.event.setArg('message','save failed... fix it!')/>
				<cfreturn false/>
			</cfcatch>
		</cftry>	

		<cfset arguments.event.setArg('message','channel saved!')/>
		<cfreturn true/>
			
	</cffunction>
	
	<cffunction name="removeChannel" access="public" returntype="boolean" output="false" hint="I save a category">
		<cfargument name="event" type="coldspring.examples.feedviewer-fb4.plugins.event" required="yes" displayname="Event"/>
		
		<cftry>
			<cfset variables.m_channelService.remove(arguments.event.getArg('channel'))/>
			<cfcatch>
				<cfset arguments.event.setArg('message','remove failed... fix it!')/>
				<cfreturn false/>
			</cfcatch>
		</cftry>	

		<cfset arguments.event.setArg('message','channel removed!')/>
		<cfreturn true/>

	
	</cffunction>	
	
</cfcomponent>
			
