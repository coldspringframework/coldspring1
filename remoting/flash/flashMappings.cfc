<!---
 
  Copyright (c) 2005, David Ross, Chris Scott, Kurt Wiersma, Sean Corfield
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
		
			
 $Id: flashMappings.cfc,v 1.2 2005/11/16 16:16:11 rossd Exp $

--->

<cfcomponent>
	<cfset variables.instance = structNew()>
	<cfset variables.instance.mappings = queryNew("cfcType,flashType")>
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="mappings" type="array" required="false" default="#arryNew(1)#">
		<cfset var i = 0>
		<cfloop from="1" to="#arrayLen(arguments.mappings)#" index="i">
			<cfset addMapping(arguments.mappings[i].cfcType, arguments.mappings[i].asType)>
		</cfloop>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="addMapping" access="public" returntype="void" output="false">
		<cfargument name="cfcType" type="string" required="true">
		<cfargument name="flashType" type="string" required="true">	
		<cfset queryAddRow(variables.instance.mappings)>
		<cfset querySetCell(variables.instance.mappings, "cfcType", arguments.cfcType)>
		<cfset querySetCell(variables.instance.mappings, "flashType", arguments.flashType)>
	</cffunction>
	
	<cffunction name="getCFCType" access="public" returntype="string" output="false">
		<cfargument name="flashType" type="string" required="true">	
		<cfset var cfcType = "">
		<cfset var findType = 0>
		<cfquery name="findType" dbtype="query">
		SELECT * FROM variables.instance.mappings 
		WHERE flashType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.flashType#">
		</cfquery>
		<cfset cfcType = findType.cfcType>
		<cfreturn cfcType>
	</cffunction>
	
	<cffunction name="getFlashType" access="public" returntype="string" output="false">
		<cfargument name="cfcType" type="string" required="true">	
		<cfset var flashType = "">
		<cfset var findType = 0>
		<cfquery name="findType" dbtype="query">
		SELECT * FROM variables.instance.mappings 
		WHERE cfcType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cfcType#">
		</cfquery>
		<cfset flashType = findType.flashType>
		<cfreturn flashType>
	</cffunction>
	
</cfcomponent>

