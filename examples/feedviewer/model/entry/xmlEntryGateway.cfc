<!---
	$Id: xmlEntryGateway.cfc,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/entry/xmlEntryGateway.cfc,v $
	$State: Exp $
	$Log: xmlEntryGateway.cfc,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/13 22:21:14  rossd
	first checkin of xml storage components
	
	Revision 1.1  2005/02/11 17:56:55  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	
	Revision 1.3  2005/02/10 16:40:09  rossd
	naming convention change to support view re-use in fb4 example
	
	Revision 1.2  2005/02/09 14:40:08  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/08 21:31:18  rossd
	*** empty log message ***
	


    Copyright (c) 2005 David Ross
--->

<cfcomponent name="XML entry Gateway" extends="coldspring.examples.feedviewer.model.entry.entryGateway" output="false">
	
	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer.model.entry.xmlEntryGateway">
		<cfargument name="datasourceSettings" type="coldspring.examples.feedviewer.model.datasource.datasourceSettings" required="true"/>
		<cfset var cffile = 0/>
		<cfset var initialContent = ""/>
		<cfset variables.dss = arguments.datasourceSettings/>
		<cfset variables.filePath = variables.dss.getXmlStoragePath() & "entry.xml" />
	
		<cfif not fileExists(variables.filePath)>
			<cfsavecontent variable="initialContent"><?xml version="1.0" encoding="UTF-8"?>
			<entries></entries>
			</cfsavecontent>
			<cffile action="write" file="#variables.filePath#" output="#initialContent#"/>			
		</cfif>

		<cfset refreshXmlContent()/>	

		<cfreturn this/>
	</cffunction>
	
	<cffunction name="setLogger" returntype="void" access="public" output="false" hint="dependency: logger">
		<cfargument name="logger" type="coldspring.examples.feedviewer.model.logging.logger" required="true"/>
		<cfset variables.m_Logger = arguments.logger/>
	</cffunction>	


	<cffunction name="refreshXmlContent" returntype="void" access="private" output="false">
		<cfset var cffile = 0/>
		<cfset var xmlContent = 0/>
		<cffile action="read" file="#variables.filePath#" variable="xmlContent"/>
		
		<cfset variables.xmlContent = xmlParse(xmlContent)/>
		<cfset variables.entries = xmlSearch(variables.xmlContent, "//entry") />
	</cffunction>
	
	<cffunction name="getAll" returntype="query" output="false" hint="I retrieve all existing entrys" access="public">
		<cfargument name="start" type="numeric" required="false" hint="start" default="0"/>
		<cfargument name="maxEntries" type="numeric" required="false" hint="number of records to fetch" default="50"/>
		
		<cfset var qGetentry = queryNew("blogTitle,xmlUrl,id,channel_id,url,authored_by,authored_on,title,body,guid") />
		
		<cfset var idx = 0/>
		
		<cfset var stOrder = structnew()/>
		<cfset var arOrder = 0/>
		
		
		<cfset variables.m_Logger.info("xmlentryGateway: fetching all entrys starting at: #arguments.start#")/>
		
		
		<cfset refreshXmlContent() />
		
		
		<cfloop from="1" to="#arrayLen(variables.entries)#" index="idx">
			<cfset stOrder[idx] = structnew()/>
			<cfset stOrder[idx].ts = createOdbcDateTime(variables.entries[idx].xmlAttributes.retrieved_on).getTime().toString()/>
		</cfloop>
		
		<cfset arOrder =  StructSort( stOrder, "numeric", "DESC", "ts") />
		
		<cfloop from="#(arguments.start+1)#" to="#min((arguments.start+arguments.maxEntries),arraylen(arOrder))#" index="idx" >
			<cfset queryAddRow(qGetentry)/>
			<cfset querySetCell(qGetentry,"id",variables.entries[arOrder[idx]].xmlAttributes.id)/>
			<cfset querySetCell(qGetentry,"blogTitle",variables.entries[arOrder[idx]].xmlAttributes.channelName)/>
			<cfset querySetCell(qGetentry,"channel_id",variables.entries[arOrder[idx]].xmlAttributes.channelID)/>
			<cfset querySetCell(qGetentry,"url",variables.entries[arOrder[idx]].xmlAttributes.url)/>
			<cfset querySetCell(qGetentry,"authored_by",variables.entries[arOrder[idx]].xmlAttributes.authored_by)/>
			<cfset querySetCell(qGetentry,"authored_on",variables.entries[arOrder[idx]].xmlAttributes.authored_on)/>															
			<cfset querySetCell(qGetentry,"guid",variables.entries[arOrder[idx]].xmlAttributes.guid)/>															
			<cfset querySetCell(qGetentry,"title",variables.entries[arOrder[idx]].xmlChildren[1].XmlText)/>															
			<cfset querySetCell(qGetentry,"body",variables.entries[arOrder[idx]].xmlChildren[2].XmlText)/>															
			
		</cfloop>

		<cfreturn qGetentry> 
	</cffunction>
	
	<cffunction name="getByChannelID" returntype="query" output="false" hint="I retrieve all existing entrys" access="public">
		<cfargument name="channelID" type="numeric" required="true" hint="aIds of the channel to restrict to"/>
		<cfargument name="maxEntries" type="numeric" required="false" default="50" hint="max number of entries to retrieve" />
		
		<cfset var qGetentry = queryNew("blogTitle,xmlUrl,id,channel_id,url,authored_by,authored_on,title,body,guid") />
		
		<cfset var idx = 0/>
		
		<cfset var stOrder = structnew()/>
		<cfset var arOrder = 0/>
		
		
		<cfset variables.m_Logger.info("xmlentryGateway: fetching entrys by channel id: #arguments.channelId#")/>
		
		
		<cfset refreshXmlContent() />
		
		
		<cfloop from="1" to="#arrayLen(variables.entries)#" index="idx">
			<cfif variables.entries[idx].xmlAttributes.channelID eq arguments.channelID>
				<cfset stOrder[idx] = structnew()/>
				<cfset stOrder[idx].ts = createOdbcDateTime(variables.entries[idx].xmlAttributes.retrieved_on).getTime().toString()/>
			</cfif>	
		</cfloop>
		
		<cfset arOrder =  StructSort( stOrder, "numeric", "DESC", "ts") />
		
		<cfloop from="1" to="#min(arguments.maxEntries,arraylen(arOrder))#" index="idx" >
			<cfset queryAddRow(qGetentry)/>
			<cfset querySetCell(qGetentry,"id",variables.entries[arOrder[idx]].xmlAttributes.id)/>
			<cfset querySetCell(qGetentry,"blogTitle",variables.entries[arOrder[idx]].xmlAttributes.channelName)/>
			<cfset querySetCell(qGetentry,"channel_id",variables.entries[arOrder[idx]].xmlAttributes.channelID)/>
			<cfset querySetCell(qGetentry,"url",variables.entries[arOrder[idx]].xmlAttributes.url)/>
			<cfset querySetCell(qGetentry,"authored_by",variables.entries[arOrder[idx]].xmlAttributes.authored_by)/>
			<cfset querySetCell(qGetentry,"authored_on",variables.entries[arOrder[idx]].xmlAttributes.authored_on)/>															
			<cfset querySetCell(qGetentry,"guid",variables.entries[arOrder[idx]].xmlAttributes.guid)/>															
			<cfset querySetCell(qGetentry,"title",variables.entries[arOrder[idx]].xmlChildren[1].XmlText)/>															
			<cfset querySetCell(qGetentry,"body",variables.entries[arOrder[idx]].xmlChildren[2].XmlText)/>															
			
		</cfloop>

		<cfreturn qGetentry> 
		
	</cffunction>	
	
</cfcomponent>