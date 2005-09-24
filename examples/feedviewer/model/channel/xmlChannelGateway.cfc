<!---
	$Id: xmlChannelGateway.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/channel/xmlChannelGateway.cfc,v $
	$State: Exp $
	$Log: xmlChannelGateway.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/13 22:21:14  rossd
	first checkin of xml storage components
	
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="XML Channel Gateway" extends="coldspring.examples.feedviewer.model.channel.channelGateway" output="false">
	
	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer.model.channel.xmlChannelGateway">
		<cfargument name="datasourceSettings" type="coldspring.examples.feedviewer.model.datasource.datasourceSettings" required="true"/>
		
		<cfset var cffile = 0/>
		<cfset var initialContent = ""/>
		<cfset variables.dss = arguments.datasourceSettings/>
		<cfset variables.filePath = variables.dss.getXmlStoragePath() & "channel.xml" />
	
		<cfif not fileExists(variables.filePath)>
			<cfsavecontent variable="initialContent"><?xml version="1.0" encoding="UTF-8"?>
			<channels></channels>
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
		<cfset variables.channels = xmlSearch(variables.xmlContent, "//channel") />
	</cffunction>
	
	
	<cffunction name="getAll" returntype="query" output="false" hint="I retrieve all existing channels" access="public">
		<cfset var qGetChannel = queryNew("id,url,title,description,entryCount")/>
		<cfset var idx = 0/>
		<cfset variables.m_Logger.info("xmlchannelGateway: fetching all channels")/>
		
		<cfset refreshXmlContent() />
		
		<cfloop from="1" to="#arrayLen(variables.channels)#" index="idx">
			<cfset queryAddRow(qGetChannel)/>
			<cfset querySetCell(qGetChannel,"id",variables.channels[idx].xmlAttributes.id)/>
			<cfset querySetCell(qGetChannel,"title",variables.channels[idx].xmlAttributes.title)/>
			<cfset querySetCell(qGetChannel,"url",variables.channels[idx].xmlAttributes.url)/>
			<cfset querySetCell(qGetChannel,"description",variables.channels[idx].xmlAttributes.description)/>						
		</cfloop>

		<cfreturn qGetChannel> 
		
	</cffunction>
	
	<cffunction name="getAllByCategories" returntype="query" output="false" hint="I retrieve all existing channels" access="public">
		<cfargument name="categoryIds" type="array" required="true" hint="array of Ids of the categories restrict to"/>
		
		
		<cfset var qGetChannel = queryNew("id,url,title,description,entryCount")/>
		<cfset var idx = 0/>
		<cfset var li = 0/>	
		<cfset var bGrabChannel = false/>	
		<cfset var lCategoryIDs = arrayToList(arguments.categoryIds)/>			
		
		<cfset variables.m_Logger.info("xmlchannelGateway: fetching channels by category ids: #arrayToList(arguments.categoryIds)#")/>
		
		<cfset refreshXmlContent() />
		
		<cfloop from="1" to="#arrayLen(variables.channels)#" index="idx">
			<cfset bGrabChannel = false/>	
			<cfloop list="#lCategoryIDs#" index="li">
				<cfif listFind(variables.channels[idx].xmlAttributes.categoryIds, li)>
					<cfset bGrabChannel = true/>	
				</cfif>
			</cfloop>
			<cfif bGrabChannel>
				<cfset queryAddRow(qGetChannel)/>
				<cfset querySetCell(qGetChannel,"id",variables.channels[idx].xmlAttributes.id)/>
				<cfset querySetCell(qGetChannel,"title",variables.channels[idx].xmlAttributes.title)/>
				<cfset querySetCell(qGetChannel,"url",variables.channels[idx].xmlAttributes.url)/>
				<cfset querySetCell(qGetChannel,"description",variables.channels[idx].xmlAttributes.description)/>						
			</cfif>
		</cfloop>
		
		<cfreturn qGetChannel> 
	</cffunction>	
	
</cfcomponent>