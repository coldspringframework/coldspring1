<!---
	$Id: category.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/category/category.cfc,v $
	$State: Exp $
	$Log: category.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/08 21:31:17  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:38  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->


<cfcomponent name="category" output="false">
	<cffunction name="init" returntype="coldspring.examples.feedviewer.model.category.category" access="public" output="false">
		<cfargument name="id" type="numeric" required="no" default="-1"/>		
		<cfargument name="name" type="string" required="no" default=""/>		
		<cfargument name="description" type="string" required="no" default=""/>	
		
		<cfset variables.instanceData = structnew()/>
		
		<cfif arguments.id gt 0>
			<cfset setId(arguments.id)/>
		</cfif>
		<cfset setName(arguments.name)/>
		<cfset setDescription(arguments.description)/>
		
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

	<cffunction name="hasId" access="public" output="false" returntype="boolean" hint="I retrieve whether the category has an id (false indicates it's a new category)">
		<cfreturn structKeyExists(variables.instanceData,'Id')/>
	</cffunction>
	
	<cffunction name="getName" access="public" output="false" returntype="string" hint="I retrieve the Name from this instance's data">
		<cfreturn variables.instanceData.Name/>
	</cffunction>

	<cffunction name="setName" access="public" output="false" returntype="void"  hint="I set the Name in this instance's data">
		<cfargument name="Name" type="string" required="true"/>
		<cfset variables.instanceData.Name = arguments.Name/>
	</cffunction>
	
	<cffunction name="getDescription" access="public" output="false" returntype="string" hint="I retrieve the Description from this instance's data">
		<cfreturn variables.instanceData.Description/>
	</cffunction>

	<cffunction name="setDescription" access="public" output="false" returntype="void"  hint="I set the Description in this instance's data">
		<cfargument name="Description" type="string" required="true"/>
		<cfset variables.instanceData.Description = arguments.Description/>
	</cffunction>
	
	
</cfcomponent>
