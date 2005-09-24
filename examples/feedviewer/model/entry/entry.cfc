<!---
	$Id: entry.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/entry/entry.cfc,v $
	$State: Exp $
	$Log: entry.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.3  2005/02/13 22:21:53  rossd
	added channel name to entry
	
	Revision 1.2  2005/02/09 04:26:41  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/08 21:31:18  rossd
	*** empty log message ***
	

    Copyright (c) 2005 David Ross
--->


<cfcomponent name="entry" output="false">
	<cffunction name="init" returntype="coldspring.examples.feedviewer.model.entry.entry" access="public" output="false">
		<cfargument name="id" type="numeric" required="no" default="-1"/>		
		<cfargument name="channelId" type="numeric" required="no" default="-1"/>		
		<cfargument name="channelName" type="string" required="no" default=""/>		
		<cfargument name="url" type="string" required="no" default=""/>		
		<cfargument name="UniqueID" type="string" required="no" default=""/>		
		<cfargument name="title" type="string" required="no" default=""/>
		<cfargument name="body" type="string" required="no" default=""/>
		<cfargument name="author" type="string" required="no" default=""/>
		<cfargument name="authorDate" type="date" required="no"/>	
		
		<cfset variables.instanceData = structnew()/>
		
		<cfif arguments.id gt 0>
			<cfset setId(arguments.id)/>
		</cfif>
		<cfif arguments.channelId gt 0>
			<cfset setChannelId(arguments.channelId)/>
			<cfset setChannelName(arguments.channelName)/>
		</cfif>
		
		<cfset setTitle(arguments.title)/>
		<cfset setUrl(arguments.url)/>		
		<cfset setUniqueID(arguments.UniqueID)/>		
		<cfset setBody(arguments.body)/>
		<cfset setAuthor(arguments.author)/>
		<cfif structKeyExists(arguments,'authorDate')>
			<cfset setAuthorDate(arguments.authorDate)/>
		</cfif>
		<cfreturn this/>		
	</cffunction>

	<cffunction name="setInstanceData" access="public" output="false" returntype="void">
		<cfargument name="data" type="struct" required="true"/>		
		<cfset variables.instanceData = arguments.data/>	
	</cffunction>

	<cffunction name="getInstanceData" access="public" output="false" returntype="struct">		
		<cfreturn variables.instanceData/>	
	</cffunction>
	
	<cffunction name="getId" access="public" output="false" returntype="numeric" hint="I retrieve the Id from this instance's data">
		<cfreturn variables.instanceData.Id/>
	</cffunction>

	<cffunction name="setId" access="public" output="false" returntype="void"  hint="I set the Id in this instance's data">
		<cfargument name="Id" type="numeric" required="true"/>
		<cfset variables.instanceData.Id = arguments.Id/>
	</cffunction>

	<cffunction name="hasId" access="public" output="false" returntype="boolean" hint="I retrieve whether the entry has an id (false indicates it's a new entry)">
		<cfreturn structKeyExists(variables.instanceData,'Id')/>
	</cffunction>

	<cffunction name="getChannelId" access="public" output="false" returntype="numeric" hint="I retrieve the ChannelId from this instance's data">
		<cfreturn variables.instanceData.ChannelId/>
	</cffunction>

	<cffunction name="setChannelId" access="public" output="false" returntype="void"  hint="I set the ChannelId in this instance's data">
		<cfargument name="ChannelId" type="numeric" required="true"/>
		<cfset variables.instanceData.ChannelId = arguments.ChannelId/>
	</cffunction>

	<cffunction name="getChannelName" access="public" output="false" returntype="string" hint="I retrieve the Channel Name from this instance's data">
		<cfreturn variables.instanceData.ChannelName/>
	</cffunction>

	<cffunction name="setChannelName" access="public" output="false" returntype="void"  hint="I set the Channel Name in this instance's data">
		<cfargument name="ChannelName" type="string" required="true"/>
		<cfset variables.instanceData.ChannelName = arguments.ChannelName/>
	</cffunction>	
	
	<cffunction name="getUrl" access="public" output="false" returntype="string" hint="I retrieve the Url from this instance's data">
		<cfreturn variables.instanceData.Url/>
	</cffunction>

	<cffunction name="setUrl" access="public" output="false" returntype="void"  hint="I set the Url in this instance's data">
		<cfargument name="Url" type="string" required="true"/>
		<cfset variables.instanceData.Url = arguments.Url/>
	</cffunction>

	<cffunction name="getTitle" access="public" output="false" returntype="string" hint="I retrieve the Title from this instance's data">
		<cfreturn variables.instanceData.Title/>
	</cffunction>

	<cffunction name="setTitle" access="public" output="false" returntype="void"  hint="I set the Title in this instance's data">
		<cfargument name="Title" type="string" required="true"/>
		<cfset variables.instanceData.Title = arguments.Title/>
	</cffunction>
	<cffunction name="getBody" access="public" output="false" returntype="string" hint="I retrieve the Body from this instance's data">
		<cfreturn variables.instanceData.Body/>
	</cffunction>

	<cffunction name="setBody" access="public" output="false" returntype="void"  hint="I set the Body in this instance's data">
		<cfargument name="Body" type="string" required="true"/>
		<cfset variables.instanceData.Body = arguments.Body/>
	</cffunction>

	<cffunction name="getUniqueID" access="public" output="false" returntype="string" hint="I retrieve the UniqueID from this instance's data">
		<cfreturn variables.instanceData.UniqueID/>
	</cffunction>

	<cffunction name="setUniqueID" access="public" output="false" returntype="void"  hint="I set the UniqueID in this instance's data">
		<cfargument name="UniqueID" type="string" required="true"/>
		<cfset variables.instanceData.UniqueID = arguments.UniqueID/>
	</cffunction>

	<cffunction name="getAuthor" access="public" output="false" returntype="string" hint="I retrieve the Author from this instance's data">
		<cfreturn variables.instanceData.Author/>
	</cffunction>

	<cffunction name="setAuthor" access="public" output="false" returntype="void"  hint="I set the Author in this instance's data">
		<cfargument name="Author" type="string" required="true"/>
		<cfset variables.instanceData.Author = arguments.Author/>
	</cffunction>

	<cffunction name="getAuthorDate" access="public" output="false" returntype="date" hint="I retrieve the AuthorDate from this instance's data">
		<cfreturn variables.instanceData.AuthorDate/>
	</cffunction>

	<cffunction name="setAuthorDate" access="public" output="false" returntype="void"  hint="I set the AuthorDate in this instance's data">
		<cfargument name="AuthorDate" type="date" required="true"/>
		<cfset variables.instanceData.AuthorDate = arguments.AuthorDate/>
	</cffunction>
	
	<cffunction name="hasAuthorDate" access="public" output="false" returntype="boolean" hint="I retrieve whether the entry has an id (false indicates it's a new entry)">
		<cfreturn structKeyExists(variables.instanceData,'AuthorDate')/>
	</cffunction>
	
</cfcomponent>
