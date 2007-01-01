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
		
			
 $Id: AbstractBeanFactory.cfc,v 1.7 2007/01/01 17:41:36 scottc Exp $

--->
 
<cfcomponent name="AbstractBeanFactory" 
			displayname="BeanFactory" 
			extends="coldspring.beans.BeanFactory"
			hint="Abstract Base Class for Bean Factory implimentations" 
			output="false">
	
	<!--- local bean factory id --->
	<cfset variables.beanFactoryId = CreateUUId() />
	<cfset variables.singletonCache = StructNew() />
	<cfset variables.aliasMap = StructNew() />
	<cfset variables.known_bf_postprocessors = "coldspring.beans.factory.config.PropertyPlaceholderConfigurer" />
			
	<cffunction name="init" access="private" returntype="void" output="false">
		<cfthrow message="Abstract CFC cannot be initialized" />
	</cffunction>
	
	<cffunction name="getBean" access="public" returntype="any" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="containsBean" access="public" returntype="boolean" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="getBeanFromSingletonCache" access="public" returntype="any" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="addBeanToSingletonCache" access="public" returntype="any" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfargument name="beanObject" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="isSingleton" access="public" returntype="boolean" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<!--- begining with ColdSpring 1.5, we will use the abstract bean factory for all base implementations
		  and keep only xml specific processing in DefaultXmlBeanFactory --->
	<cffunction name="registerAlias" access="public" returntype="void" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfargument name="alias" type="string" required="true" />
		<cfset var duplicateAlias = "" />
		<cfset var sys = CreateObject('java','java.lang.System') />
		<cflock name="bf_#variables.beanFactoryId#.AliasMap" type="exclusive" timeout="5">
			<cfif StructKeyExists(variables.aliasMap, arguments.alias)>
				<cfset duplicateAlias = variables.aliasMap[arguments.alias] />
			<cfelse>
				<cfset variables.aliasMap[arguments.alias] = arguments.beanName />
				<cfset sys.out.println("Registering alias #arguments.alias# for bean #arguments.beanName#")/>
			</cfif>
		</cflock>
		
		<cfif len(duplicateAlias)>
			<cfthrow type="ColdSpring.AliasException" 
					 detail="The alias #arguments.alias# is already registered for bean #duplicateAlias#"/>
		</cfif>
	</cffunction>
	
	<cffunction name="resolveBeanName" access="public" returntype="string" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfset var beanName = "" />
		<cfset var sys = CreateObject('java','java.lang.System') />
		<!--- first look to resolve alias, if we don;t have the alias mapped, return supplied bean name --->
		<cflock name="bf_#variables.beanFactoryId#.AliasMap" type="readonly" timeout="5">
			<cfif StructKeyExists(variables.aliasMap, arguments.name)>
				<cfset beanName = variables.aliasMap[arguments.name] />
			</cfif>
		</cflock>
		
		<cfif len(beanName)>
			<cfset sys.out.println("Retrieved bean #beanName# for alias #arguments.name#")/>
			<cfreturn beanName />
		<cfelse>
			<cfset sys.out.println("Bean name #arguments.name# is a proper bean")/>
			<cfreturn name />
		</cfif>
	</cffunction>

</cfcomponent>