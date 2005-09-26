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

 $Id: AopProxyBean.cfc,v 1.3 2005/09/26 15:48:12 scottc Exp $
 $log$
	
---> 
 
<cfcomponent name="${name}" 
			displayname="AopProxyBean" 
			extends="${extends}"
			hint="Abstract Base Class for Aop Proxy Bans" 
			output="false">
			
	<cffunction name="init" access="public" returntype="${extends}" output="false">
		<cfargument name="target" type="any" required="true" />
		<cfset variables.target = arguments.target />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setAdviceChains" access="public" returntype="void" output="false">
		<cfargument name="adviceChains" type="struct" required="true" />
		<cfset variables.adviceChains = arguments.adviceChains />
	</cffunction>
	
	<cffunction name="getAdviceChains" access="public" returntype="struct" output="false">
		<cfreturn variables.adviceChains />
	</cffunction>

	<cffunction name="callMethod" access="public" returntype="any">
		<cfargument name="methodName" type="string" required="true" />
		<cfargument name="args" type="struct" required="true" />
		<cfset var method = CreateObject('component','coldspring.aop.Method') />
		<cfset var rtn = 0 />
		<cfset var adviceChain = 0 />
		<cfset var advice = 0 />
		<cfset var advIx = 0 />
		
		<!--- first create a method object to pass through advice chain --->
		<cfset method.init(variables.target, arguments.methodName, arguments.args) />
		
		<!--- now find advice chains to call --->
		<cfif StructKeyExists(variables.adviceChains, arguments.methodName)>
			<!--- first call any before methods --->
			<cfset adviceChain = variables.adviceChains[arguments.methodName].getAdvice('before') />
			<cfloop from="1" to="#ArrayLen(adviceChain)#" index="advIx">
				<cfset adviceChain[advIx].before(method, arguments.args, variables.target) />
			</cfloop>
			
			<!--- next around advice --->
			<cfset adviceChain = variables.adviceChains[arguments.methodName].getAdvice('around') />
			<cfif ArrayLen(adviceChain)>
				<!--- now if there's an around advice call that --->
				<cfset rtn = adviceChain[1].around(method, argumenths.args, variables.target) />
			<cfelse>
				<!--- or call the method --->
				<cfset rtn = method.proceed() />
				<cfif not isDefined('rtn')>
					<cfset rtn = 0 />
				</cfif>
			</cfif>
			
			<!--- now any after returning advice --->
			<cfset adviceChain = variables.adviceChains[arguments.methodName].getAdvice('afterReturning') />
			<cfloop from="1" to="#ArrayLen(adviceChain)#" index="advIx">
				<cfset rtn = adviceChain[advIx].afterReturning(rtn, method, arguments.args, variables.target) />
			</cfloop>
		<cfelse>
			<!--- if there's no advice chains to execute, just call the method --->
			<cfset rtn = method.proceed() />
		</cfif>
		
		<cfreturn rtn />
	</cffunction>
	
</cfcomponent>