<!---
	$Id: aggregatorManager.cfc,v 1.1 2005/09/24 22:12:43 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer-fb4/controller/aggregatorManager.cfc,v $
	$State: Exp $
	$Log: aggregatorManager.cfc,v $
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

<cfcomponent name="aggregatorManager.cfc" output="false">
	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer-fb4.controller.aggregatorManager" output="false">
		<cfargument name="serviceFactory" type="coldspring.beans.BeanFactory" required="yes"/>
		<cfset variables.m_aggregatorService = arguments.serviceFactory.getBean('aggregatorService')/>
		<cfreturn this/>
	</cffunction>
	
	
	<cffunction name="aggregrateChannelFeed" access="public" returntype="void" output="false" hint="I retrieve a aggregator">
		<cfargument name="event" type="coldspring.examples.feedviewer-fb4.plugins.event" required="yes" displayname="Event"/>
		
		<cftry>
			<cfset variables.m_aggregatorService.aggregateEntriesByChannel(arguments.event.getArg('channel'))/>
			<cfcatch>
				<cfset arguments.event.setArg('message','aggregation failed... reason: #cfcatch.message#!')/>
			</cfcatch>
		</cftry>	

		<cfset arguments.event.setArg('message','entries refreshed!')/>

	</cffunction>
</cfcomponent>
			
