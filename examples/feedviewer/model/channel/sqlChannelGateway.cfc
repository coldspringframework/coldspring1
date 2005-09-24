<!---
	$Id: sqlChannelGateway.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/channel/sqlChannelGateway.cfc,v $
	$State: Exp $
	$Log: sqlChannelGateway.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/13 22:22:00  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/11 17:56:55  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	
	Revision 1.2  2005/02/08 21:31:18  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:39  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Sql Channel Gateway" extends="coldspring.examples.feedviewer.model.channel.channelGateway" output="false">
	
	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer.model.channel.sqlChannelGateway">
		<cfargument name="datasourceSettings" type="coldspring.examples.feedviewer.model.datasource.datasourceSettings" required="true"/>
		<cfset variables.dss = arguments.datasourceSettings/>
		<cfreturn this/>
	</cffunction>

	<cffunction name="setLogger" returntype="void" access="public" output="false" hint="dependency: logger">
		<cfargument name="logger" type="coldspring.examples.feedviewer.model.logging.logger" required="true"/>
		<cfset variables.m_Logger = arguments.logger/>
	</cffunction>	
	
	<cffunction name="getAll" returntype="query" output="false" hint="I retrieve all existing channels" access="public">
		<cfset var qGetChannel = 0/>
		
		<cfset variables.m_Logger.info("sqlchannelGateway: fetching all channels")/>
		
		<cfquery name="qGetChannel" datasource="#variables.dss.getDatasourceName()#">
		select ch.id, ch.url, ch.title, ch.description, e.entryCount
		from channel ch
		left outer join (
        select count(fk_channel_id) as entryCount, fk_channel_id
        from entry
        group by fk_channel_id) e on ch.id = e.fk_channel_id
        order by ch.title
		</cfquery>
		
		<cfreturn qGetChannel> 
		
	</cffunction>
	
	<cffunction name="getAllByCategories" returntype="query" output="false" hint="I retrieve all existing channels" access="public">
		<cfargument name="categoryIds" type="array" required="true" hint="array of Ids of the categories restrict to"/>
		
		<cfset var qGetChannel = 0/>
		
		<cfset variables.m_Logger.info("sqlchannelGateway: fetching channels by category ids: #arrayToList(arguments.categoryIds)#")/>
		
		<cfquery name="qGetChannel" datasource="#variables.dss.getDatasourceName()#">
		select ch.id, ch.url, ch.title, ch.description, e.entryCount
		from channel ch
        inner join category_channels c on ch.id = c.fk_channel_id
		left outer join (
        select count(fk_channel_id) as entryCount, fk_channel_id
        from entry
        group by fk_channel_id) e on ch.id = e.fk_channel_id
        where c.fk_category_id in (<cfqueryparam cfsqltype="cf_sql_integer" value="#arrayToList(arguments.categoryIds)#" list="yes"/>)									  
        order by ch.title
		</cfquery>
		
		<cfreturn qGetChannel> 
		
	</cffunction>	
	
</cfcomponent>