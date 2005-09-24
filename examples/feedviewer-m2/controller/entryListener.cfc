<!---
	$Id: entryListener.cfc,v 1.1 2005/09/24 22:12:44 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer-m2/controller/entryListener.cfc,v $
	$State: Exp $
	$Log: entryListener.cfc,v $
	Revision 1.1  2005/09/24 22:12:44  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/11 02:05:43  rossd
	mach-ii split out into it's own folder
	
	Revision 1.2  2005/02/09 14:39:54  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/08 21:31:17  rossd
	*** empty log message ***
	


    Copyright (c) 2005 David Ross
--->

<cfcomponent name="entryListener.cfc" extends="MachII.framework.listener" output="false">
	<cffunction name="configure" access="public" returntype="void" output="false">
		<cfset var sf = getProperty('serviceFactory')/>
		<cfset variables.m_entryService = sf.getBean('entryService')/>
	</cffunction>
	
	<cffunction name="getAllEntries" returntype="query" access="public" output="false" hint="I retrieve all existing categories">
		<cfargument name="event" type="MachII.framework.Event" required="yes" displayname="Event"/>	
		<cfreturn variables.m_entryService.getAll(arguments.event.getArg('start','0'))/>
	</cffunction>
	
	<cffunction name="getEntriesByChannelId" returntype="query" access="public" output="false" hint="I retrieve a entry">
		<cfargument name="event" type="MachII.framework.Event" required="yes" displayname="Event"/>
		<cfreturn variables.m_entryService.getByChannelId(arguments.event.getArg('channel').getId(),arguments.event.getArg('max','50'))/>		
	</cffunction>	
	
	<cffunction name="getentrysByCategoryId" access="public" returntype="query" output="false" hint="I retrieve a category">
		<cfargument name="event" type="MachII.framework.Event" required="yes" displayname="Event"/>
	
		<cfreturn variables.m_entryService.getAllByCategory(listToArray(arguments.event.getArg('categoryId')))/>
	
	</cffunction>

</cfcomponent>
			

