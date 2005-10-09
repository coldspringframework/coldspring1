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

 $Id: AopProxyBean.cfc,v 1.7 2005/10/09 16:12:58 scottc Exp $
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
			
			<!---  for methodInterceptors, the advice chain will create a proper interceptorChain --->
			<cfset adviceChain = variables.adviceChains[arguments.methodName].getInterceptorChain(method, arguments.args, variables.target) />
			<cfset rtn = adviceChain.proceed() />
			
			<!--- now any after returning advice --->
			<cfset adviceChain = variables.adviceChains[arguments.methodName].getAdvice('afterReturning') />
			<cfloop from="1" to="#ArrayLen(adviceChain)#" index="advIx">
				<cfset rtn = adviceChain[advIx].afterReturning(rtn, method, arguments.args, variables.target) />
			</cfloop>
		<cfelse>
			<!--- if there's no advice chains to execute, just call the method --->
			<cfset rtn = method.proceed() />
		</cfif>
		
		<cfif isDefined('rtn')>
			<cfreturn rtn />
		</cfif>
	</cffunction>
	
</cfcomponent>