<!---
	$Id: sqlEntryDAO.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/entry/sqlEntryDAO.cfc,v $
	$State: Exp $
	$Log: sqlEntryDAO.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/11 17:56:55  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	
	Revision 1.4  2005/02/10 16:40:09  rossd
	naming convention change to support view re-use in fb4 example
	
	Revision 1.3  2005/02/09 04:26:41  rossd
	*** empty log message ***
	
	Revision 1.2  2005/02/08 21:31:18  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:39  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="MySQL entry DAO" output="false" extends="coldspring.examples.feedviewer.model.entry.entryDAO">
	
	<cffunction name="init" access="public" output="false" returntype="coldspring.examples.feedviewer.model.entry.sqlEntryDAO">
		<cfargument name="datasourceSettings" type="coldspring.examples.feedviewer.model.datasource.datasourceSettings" required="true"/>
		<cfset variables.dss = arguments.datasourceSettings/>
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="setLogger" returntype="void" access="public" output="false" hint="dependency: logger">
		<cfargument name="logger" type="coldspring.examples.feedviewer.model.logging.logger" required="true"/>
		<cfset variables.m_Logger = arguments.logger/>
	</cffunction>	
	
	<cffunction name="fetch" returntype="coldspring.examples.feedviewer.model.entry.entry" output="false" access="public" hint="I retrieve a entry">
		<cfargument name="entryIdentifier" type="any" required="true" hint="I am the unique ID of the entry to be retrieved"/>
		<cfset var qGetentry = 0/>
		<cfset var entry = createObject("component","coldspring.examples.feedviewer.model.entry.entry").init()/>
		
		<cfset variables.m_Logger.info("sqlentryDAO: fetching entry with id = #arguments.entryIdentifier#")/>
		
		<cfreturn entry/>

	</cffunction>

	<cffunction name="save" returntype="void" output="false" access="public" hint="I save a entry">
		<cfargument name="entry" type="coldspring.examples.feedviewer.model.entry.entry" hint="I am the entry to be saved" required="true"/>
		<cfset var qCkEntry = 0/>
		
		<cfif arguments.entry.hasId()>
			<cfset update(arguments.entry)/>
		<cfelse>
			<!--- check to see if guid/title already exists --->
			<cfquery name="qCkEntry" datasource="#variables.dss.getDatasourceName()#">
			select guid from entry
			where guid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getUniqueId()#"/>
			and fk_channel_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getChannelID()#"/>
			</cfquery>
			
			<cfif qCkEntry.recordcount gt 0>
				<cfset update(arguments.entry)/>
			<cfelse>
				<cfset create(arguments.entry)/>
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="remove" returntype="void" output="false" access="public" hint="I remove a entry">
		<cfargument name="entry" type="coldspring.examples.feedviewer.model.entry.entry" hint="I am the entry to be removed" required="true"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
	<cffunction name="create" returntype="void" output="false" access="public" hint="I save a entry">
		<cfargument name="entry" type="coldspring.examples.feedviewer.model.entry.entry" hint="I am the entry to be saved" required="true"/>
		<cfset var qInsEntry = 0/>
		<cfquery name="qGetentry" datasource="#variables.dss.getDatasourceName()#">
		insert into entry
		(fk_channel_id, url, guid, title, body, authored_by, authored_on)
		values
		(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.entry.getChannelId()#"/>,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getUrl()#"/>,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getUniqueId()#"/>,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getTitle()#"/>,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getBody()#"/>,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getAuthor()#"/>,
			<cfif arguments.entry.hasAuthorDate()>
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#createODBCDateTime(arguments.entry.getAuthorDate())#"/>
			<cfelse>
				<cfqueryparam cfsqltype="cf_sql_timestamp" null="yes"/>
			</cfif>)
		</cfquery>
	</cffunction>

	<cffunction name="update" returntype="void" output="false" access="public" hint="I save a entry">
		<cfargument name="entry" type="coldspring.examples.feedviewer.model.entry.entry" hint="I am the entry to be saved" required="true"/>
		<cfset var qInsEntry = 0/>
		<cfquery name="qGetentry" datasource="#variables.dss.getDatasourceName()#">
		update entry
		set url=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getUrl()#"/>,
		    title=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getTitle()#"/>,
		    body=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getBody()#"/>,
		    authored_by=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getAuthor()#"/>,
		    <cfif arguments.entry.hasAuthorDate()>
				authored_on=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#createODBCDateTime(arguments.entry.getAuthorDate())#"/>
			<cfelse>
				authored_on=<cfqueryparam cfsqltype="cf_sql_timestamp" null="yes"/>
			</cfif>
		
		where guid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getUniqueId()#"/>
			<cfif arguments.entry.hasId()>
			and id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entry.getId()#"/>
			</cfif>
		</cfquery>
	</cffunction>	
	
</cfcomponent>