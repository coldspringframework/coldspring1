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

 $Id: AbstractPointcutAdvisor.cfc,v 1.3 2005/09/26 15:48:12 scottc Exp $
 $log$
	
---> 
 
<cfcomponent name="AbstractPointcutAdvisor" 
			displayname="AbstractPointcutAdvisor" 
			extends="coldspring.aop.Advisor"
			hint="Abstract Base Class for Pointcut Advisor implimentations" 
			output="false">
			
	<cfset variables.order = 999 />
	<cfset variables.advice = 0 />
			
	<cffunction name="init" access="private" returntype="void" output="false">
		<cfthrow message="Abstract CFC. Cannot be initialized" />
	</cffunction>
	
	<cffunction name="setOrder" access="public" returntype="void" output="false">
		<cfargument name="order" type="numeric" required="true" />
		<cfset variables.order = arguments.order />
	</cffunction>
	
	<cffunction name="getOrder" access="public" returntype="numeric" output="false">
		<cfreturn variables.order />
	</cffunction>
	
	<cffunction name="setAdvice" access="public" returntype="void" output="false">
		<cfargument name="advice" type="coldspring.aop.Advice" required="true" />
		<cfset variables.advice = arguments.advice />
	</cffunction>
	
	<cffunction name="getAdvice" access="public" returntype="coldspring.aop.Advice" output="false">
		<cfreturn variables.advice />
	</cffunction>
	
</cfcomponent>