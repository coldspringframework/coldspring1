<!---
	$Id: aggregatorListener.cfc,v 1.1 2005/09/24 22:12:44 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer-m2/controller/aggregatorListener.cfc,v $
	$State: Exp $
	$Log: aggregatorListener.cfc,v $
	Revision 1.1  2005/09/24 22:12:44  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/11 02:05:43  rossd
	mach-ii split out into it's own folder
	
	Revision 1.4  2005/02/09 14:39:54  rossd
	*** empty log message ***
	
	Revision 1.3  2005/02/09 04:26:41  rossd
	*** empty log message ***
	
	Revision 1.2  2005/02/08 21:31:17  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:38  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="aggregatorListener.cfc" extends="MachII.framework.listener" output="false">
	<cffunction name="configure" access="public" returntype="void" output="false">
		<cfset var sf = getProperty('serviceFactory')/>
		<cfset variables.m_aggregatorService = sf.getBean('aggregatorService')/>
	</cffunction>
	
	
	<cffunction name="aggregrateChannelFeed" access="public" returntype="void" output="false" hint="I retrieve a aggregator">
		<cfargument name="event" type="MachII.framework.Event" required="yes" displayname="Event"/>
		
		<cftry>
			<cfset variables.m_aggregatorService.aggregateEntriesByChannel(arguments.event.getArg('channel'))/>
			<cfcatch>
				<cfset arguments.event.setArg('message','aggregation failed... reason: #cfcatch.message#!')/>
				<cfreturn/>
			</cfcatch>
		</cftry>	

		<cfset arguments.event.setArg('message','entries refreshed!')/>

	</cffunction>
</cfcomponent>
			
