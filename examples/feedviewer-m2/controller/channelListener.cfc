<!---
	$Id: channelListener.cfc,v 1.1 2005/09/24 22:12:44 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer-m2/controller/channelListener.cfc,v $
	$State: Exp $
	$Log: channelListener.cfc,v $
	Revision 1.1  2005/09/24 22:12:44  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/11 17:56:55  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	
	Revision 1.1  2005/02/11 02:05:43  rossd
	mach-ii split out into it's own folder
	
	Revision 1.5  2005/02/10 16:40:08  rossd
	naming convention change to support view re-use in fb4 example
	
	Revision 1.4  2005/02/09 15:07:08  rossd
	*** empty log message ***
	
	Revision 1.3  2005/02/09 04:26:41  rossd
	*** empty log message ***
	
	Revision 1.2  2005/02/08 21:31:17  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:38  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="channelListener.cfc" extends="MachII.framework.listener" output="false">
	<cffunction name="configure" access="public" returntype="void" output="false">
		<cfset var sf = getProperty('serviceFactory')/>
		<cfset variables.m_channelService = sf.getBean('channelService')/>
	</cffunction>
	
	<cffunction name="getAllChannels" returntype="query" access="public" output="false" hint="I retrieve all existing categories">
		<cfreturn variables.m_channelService.getAll()/>
	</cffunction>
	
	<cffunction name="getChannelById" returntype="coldspring.examples.feedviewer.model.channel.channel" access="public" output="false" hint="I retrieve a channel">
		<cfargument name="event" type="MachII.framework.Event" required="yes" displayname="Event"/>
		<cfreturn variables.m_channelService.getById(arguments.event.getArg('channelId'))/>		
	</cffunction>	
	
	<cffunction name="getChannelsByCategoryId" access="public" returntype="query" output="false" hint="I retrieve a category">
		<cfargument name="event" type="MachII.framework.Event" required="yes" displayname="Event"/>
	
		<cfreturn variables.m_channelService.getAllByCategory(listToArray(arguments.event.getArg('categoryId')))/>
	
	</cffunction>
	
	<cffunction name="saveChannel" access="public" returntype="void" output="false" hint="I save a channel">
		<cfargument name="event" type="MachII.framework.Event" required="yes" displayname="Event"/>
		
		<cftry>
			<cfset variables.m_channelService.save(arguments.event.getArg('channel'))/>
			<cfcatch>
				<cfset arguments.event.setArg('message','save failed... fix it! (#cfcatch.message#)')/>
				<cfset announceEvent('renderchannel', arguments.event.getArgs())/>
				<cfreturn/>
			</cfcatch>
		</cftry>	

		<cfset arguments.event.setArg('message','channel saved!')/>
		<cfset announceEvent('c.showHome', arguments.event.getArgs())/>
			
	</cffunction>
	
	<cffunction name="removeChannel" access="public" returntype="void" output="false" hint="I save a category">
		<cfargument name="event" type="MachII.framework.Event" required="yes" displayname="Event"/>
		
		<cftry>
			<cfset variables.m_channelService.remove(arguments.event.getArg('channel'))/>
			<cfcatch>
				<cfset arguments.event.setArg('message','remove failed... fix it!')/>
				<cfset announceEvent('renderchannel', arguments.event.getArgs())/>
				<cfreturn/>
			</cfcatch>
		</cftry>	

		<cfset arguments.event.setArg('message','channel removed!')/>
		<cfset announceEvent('c.showHome', arguments.event.getArgs())/>

	
	</cffunction>	
	
</cfcomponent>
			
