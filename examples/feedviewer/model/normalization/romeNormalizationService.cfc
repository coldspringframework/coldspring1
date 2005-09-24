<!---
	$Id: romeNormalizationService.cfc,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/normalization/romeNormalizationService.cfc,v $
	$State: Exp $
	$Log: romeNormalizationService.cfc,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.3  2005/02/09 14:40:09  rossd
	*** empty log message ***
	
	Revision 1.2  2005/02/09 04:26:41  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/08 21:31:18  rossd
	*** empty log message ***
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="romeNormalizationService" output="false" extends="coldspring.examples.feedviewer.model.normalization.normalizationService">
	
	
	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer.model.normalization.romeNormalizationService" output="false">
	
		<cfreturn this/>
	
	</cffunction>
	
	
	<cffunction name="normalize" returntype="array" output="false" hint="Returns an array of structs containing author, content, date, id, link, and title members. Also returns an isHtml member that is set to 'true' when the content element contains HTML." access="public">
		<cfargument name="url" type="string" required="true"/>
		
		<cfset var jUrl = createObject("java","java.net.URL").init(arguments.url)/>
		<cfset var xmlReader = createObject("java","com.sun.syndication.io.XmlReader").init(jUrl)/>
		<cfset var feed = createObject("java","com.sun.syndication.io.SyndFeedInput").build(xmlReader)/>
		<cfset var entries = feed.getEntries()/>
		<cfset var rtnArray = arraynew(1)/>
		<cfset var entryIdx = 0/>
		<cfset var entry = 0/>		
		<cfset var newEntry = structnew()/>
		
		<cfloop from="1" to="#arraylen(entries)#" index="entryIdx">
			<cfset newEntry.id = entries[entryIdx].getUri()/>
			<cfset newEntry.author = entries[entryIdx].getAuthor()/>
			<cfset newEntry.title = entries[entryIdx].getTitle()/>
			<cfset newEntry.content = entries[entryIdx].getDescription().getValue()/>
			<cfset newEntry.date = entries[entryIdx].getPublishedDate()/>
			<cfset newEntry.link = entries[entryIdx].getLink()/>
			
			<!--- this is really dumb, but we need to convert java nulls into cfml zero-length strings.
				  I may move this into a custom java wrapper for com.sun.syndication.io.SyndEntry if performance
				  becomes an issue --->
				  
			<cfset checkNulls(newEntry)/>
			
			<cfset arrayAppend(rtnArray,duplicate(newEntry))/>
			
		</cfloop>
		<cfreturn rtnArray/>
	</cffunction>
	
	<cffunction name="checkNulls" returntype="void" access="private">
		<cfargument name="structToCheck" type="struct"/>
		<cfset var key = 0/>
		<cfset var assignVal = 0/>
		<cfloop collection="#arguments.structToCheck#" item="key">
			<cftry>
				<cfset assignVal = arguments.structToCheck[key]/>
				<cfcatch>
					<cfset arguments.structToCheck[key] = ""/>
				</cfcatch>
			</cftry>
		</cfloop>
	</cffunction>
	
</cfcomponent>
