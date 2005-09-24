<!---
	$Id: entryService.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/entry/entryService.cfc,v $
	$State: Exp $
	$Log: entryService.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.4  2005/02/13 17:50:24  rossd
	added maxEntries to getAll(start,max)
	
	Revision 1.3  2005/02/09 14:40:08  rossd
	*** empty log message ***
	
	Revision 1.2  2005/02/08 21:31:18  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:39  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Entry Service" output="false">

	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer.model.entry.entryService" output="false">
	
		<cfreturn this/>
	
	</cffunction>

	<cffunction name="setEntryDAO" returntype="void" access="public"	output="false" hint="dependency: entryDAO">
		<cfargument name="entryDAO" type="coldspring.examples.feedviewer.model.entry.entryDAO"	required="true"/>
		
		<cfset variables.m_entryDAO = arguments.entryDAO/>
			
	</cffunction>	

	<cffunction name="setEntryGateway" returntype="void" access="public" output="false" hint="dependency: entryGateway">
		<cfargument name="entryGateway" type="coldspring.examples.feedviewer.model.entry.entryGateway" required="true"/>
		<cfset variables.m_entryGateway = arguments.entryGateway/>
	</cffunction>
	
	<cffunction name="save" returntype="void" access="public"	output="false" hint="dependency: entryDAO">
		<cfargument name="entry" type="coldspring.examples.feedviewer.model.entry.entry"	required="true"/>
		
		<cfset variables.m_entryDAO.save(arguments.entry)/>
	</cffunction>	

	<cffunction name="getByChannelId" returntype="query" access="public" output="false" hint="I retrieve a channel by id">
		<cfargument name="channelId" type="numeric" required="true" hint="id of channel to get"/>
		<cfargument name="maxEntries" type="numeric" required="false" default="50" hint="max number of entries to retrieve" />
		<cfreturn variables.m_entryGateway.getByChannelId(arguments.channelId,arguments.maxEntries)/>
	</cffunction>

	<cffunction name="getAll" returntype="query" access="public" output="false" hint="I retrieve entries">
		<cfargument name="start" type="numeric" required="false" default="0" hint="record to start at"/>
		<cfargument name="maxEntries" type="numeric" required="false" default="50" hint="num records to get"/>
		<cfreturn variables.m_entryGateway.getAll(arguments.start,arguments.maxEntries)/>
	</cffunction>
		
</cfcomponent>