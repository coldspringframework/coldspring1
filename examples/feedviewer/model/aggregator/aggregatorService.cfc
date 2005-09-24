<!---
	$Id: aggregatorService.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/aggregator/aggregatorService.cfc,v $
	$State: Exp $
	$Log: aggregatorService.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.4  2005/02/13 22:21:53  rossd
	added channel name to entry
	
	Revision 1.3  2005/02/09 04:26:41  rossd
	*** empty log message ***
	
	Revision 1.2  2005/02/08 21:31:17  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:38  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Aggregator Service" output="false">

	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer.model.aggregator.aggregatorService" output="false">
	
		<cfreturn this/>
	
	</cffunction>

	<cffunction name="setNormalizationService" returntype="void" access="public"	output="false" hint="dependency: normalizationService">
		<cfargument name="normalizationService" type="coldspring.examples.feedviewer.model.normalization.normalizationService"	required="true"/>
		<cfset variables.m_normalizationService = arguments.normalizationService/>
	</cffunction>	
	
	<cffunction name="setEntryService" returntype="void" access="public"	output="false" hint="dependency: entryService">
		<cfargument name="entryService" type="coldspring.examples.feedviewer.model.entry.entryService" required="true"/>
		<cfset variables.m_entryService = arguments.entryService/>
	</cffunction>	
		
	
	<cffunction name="aggregateEntriesByChannel" returntype="void" access="public" output="false" hint="I aggregate and store all entries for a supplied channel">
		<cfargument name="channel" type="coldspring.examples.feedviewer.model.channel.channel"	required="true"/>
		
		<cfset var normalizedEntries = variables.m_normalizationService.normalize(arguments.channel.getUrl())/>
		<cfset var entryIndex = 0/>
		<cfset var entryData = structnew()/>
		
		<cfset entryData.channelID = arguments.channel.getId()/>
		<cfset entryData.channelName = arguments.channel.getTitle()/>
		
		<cfloop from="1" to="#arraylen(normalizedEntries)#" index="entryIndex">
			<cfset entryData.UniqueID = normalizedEntries[entryIndex].id/>
			<cfset entryData.Title = normalizedEntries[entryIndex].title/>		
			<cfset entryData.Url = normalizedEntries[entryIndex].link/>
			<cfset entryData.Body = normalizedEntries[entryIndex].content/>
			<cfset entryData.Author = normalizedEntries[entryIndex].Author/>					
			<cfif len(normalizedEntries[entryIndex].Date)>
				<cfset entryData.AuthorDate = normalizedEntries[entryIndex].Date/>			
			</cfif>
			
			<!--- (attempt to) save the entry --->
			<cfset variables.m_entryService.save(createObject('component','coldspring.examples.feedviewer.model.entry.entry').init(argumentcollection=entryData))/>
			
		</cfloop>
		
		
	</cffunction>
	
	<cffunction name="getById" returntype="coldspring.examples.feedviewer.model.category.category" access="public" output="false" hint="I retrieve a category">
		<cfargument name="categoryId" type="numeric" required="true"/>
		<cfreturn variables.m_CategoryDAO.fetch(arguments.categoryId)/>
	</cffunction>
	
</cfcomponent>