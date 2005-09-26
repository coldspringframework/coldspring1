<!---
	  
  Copyright (c) 2005, Chris Scott
  All rights reserved.
	
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

 $Id: NamedMethodPointcutAdvisor.cfc,v 1.3 2005/09/26 15:48:12 scottc Exp $
 $log$
	
---> 
 
<cfcomponent name="NamedMethodPointcutAdvisor" 
			displayname="NamedMethodPointcutAdvisor" 
			extends="coldspring.aop.support.DefaultPointcutAdvisor" 
			hint="Pointcut Advisor to match method names (with wildcard)" 
			output="false">
	
	<cffunction name="init" access="public" returntype="coldspring.aop.support.NamedMethodPointcutAdvisor" output="false">
		<cfset setPointcut(CreateObject('component','coldspring.aop.support.NamedMethodPointcut').init()) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setMappedName" access="public" returntype="void" output="false">
		<cfargument name="mappedName" type="string" required="true" />
		<cfset variables.pointcut.setMappedName(arguments.mappedName) />
	</cffunction>
	
	<cffunction name="setMappedNames" access="public" returntype="void" output="false">
		<cfargument name="mappedNames" type="string" required="true" />
		<cfset variables.pointcut.setMappedNames(arguments.mappedNames) />
	</cffunction>
	
	<cffunction name="matches" access="public" returntype="boolean" output="true">
		<cfargument name="methodName" type="string" required="true" />
		<cfreturn variables.pointcut.matches(arguments.methodName) />
	</cffunction>
	
	<cffunction name="getPointcut" access="public" returntype="coldspring.aop.Pointcut" output="false">
		<cfreturn variables.pointcut  />
	</cffunction>
				
</cfcomponent>