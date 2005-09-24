<!---
	$Id: remoteFacade.cfc,v 1.1 2005/09/24 22:12:44 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer-remote/remoteFacade.cfc,v $
	$State: Exp $
	$Log: remoteFacade.cfc,v $
	Revision 1.1  2005/09/24 22:12:44  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/13 17:48:04  rossd
	first check in of feedviewer - remote
	
	
    Copyright (c) 2005 David Ross
--->


<cfcomponent displayname="Remote Facade" output="false" hint="I am a remote facade for feedviewer">
	
	<cffunction name="getAllChannels" returntype="query" access="remote" output="false" hint="I retrieve all existing channels">
		<!--- remember, each remote call will cause a new instance of this cfc to be created 
		  thus, we will reference the service factory thru the application scope:
		--->
		<cfset var channelService = application.serviceFactory.getBean('channelService') />
		<cfreturn channelService.getAll()/>
	</cffunction>

	<cffunction name="getAllCategories" returntype="query" access="remote" output="false" hint="I retrieve all existing channel categories">
		<cfset var categoryService = application.serviceFactory.getBean('categoryService') />
		<cfreturn categoryService.getAllCategories()/>
	</cffunction>

	<cffunction name="getChannelsByCategoryIds" returntype="query" access="remote" output="false" hint="I retrieve all existing channels within a given category ID">
		<cfargument name="categoryID" type="numeric" required="true" hint="I am the category ID to fetch the channels by"/>
		<cfset var channelService = application.serviceFactory.getBean('channelServiceyService') />
		<!--- channelService expects an array of category ids, but since this method only retrieves 1 at a time, we place the supplied categoryID into an array: --->
		<cfreturn channelService.getAllByCategory(listToArray(categoryID))/>
	</cffunction>	

	<cffunction name="getRecentEntries" returntype="query" access="remote" output="false" hint="I retrieve the most recent entries">
		<cfargument name="maxEntries" type="numeric" required="true"/>
		<cfset var entryService = application.serviceFactory.getBean('entryService') />
		<cfreturn entryService.getAll(0,arguments.maxEntries)/>
	</cffunction>

	<cffunction name="refreshAllChannels" returntype="void" access="remote" output="false" hint="I will aggregate all the newest entries for each channel in the system. I would probably be called on a repeating schedule, to keep the entries up to date.">
		<cfargument name="maxEntries" type="numeric" required="false" default="50" />
		
		<!--- get all channels: --->
		<cfset var channelService = application.serviceFactory.getBean('channelService') />
		<cfset var allChannels = channelService.getAll() />
		
		<!--- get a reference to the aggregator service --->
		<cfset var aggregatorService = variables.serviceFactory.getBean('aggregatorService')/>
		
		<!--- loop over the channels, obtaining a channel instance for each to be passed to the aggregatorService  --->
		<cfloop query="allChannels">
			<cfset aggregatorService.aggregateEntriesByChannel(
				   										channelService.getById(allChannels.id)
																)/>
		
		</cfloop>
		
	</cffunction>


</cfcomponent>