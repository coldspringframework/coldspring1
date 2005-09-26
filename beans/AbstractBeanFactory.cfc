<!---
 
  Copyright (c) 2002-2005	David Ross,	Chris Scott
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
		
			
 $Id: AbstractBeanFactory.cfc,v 1.4 2005/09/26 02:01:03 rossd Exp $

--->
 
<cfcomponent name="AbstractBeanFactory" 
			displayname="BeanFactory" 
			extends="coldspring.beans.BeanFactory"
			hint="Abstract Base Class for Bean Factory implimentations" 
			output="false">
			
	<cfset variables.singletonCache = StructNew() />
			
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

</cfcomponent>