<!---
	 $Id: AopProxyBean.cfc,v 1.1 2005/09/13 17:01:53 scottc Exp $
	 $log$
	
	Copyright (c) 2005, Chris Scott
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without modification, 
	are permitted provided that the following conditions are met:
	
	    ¥ Redistributions of source code must retain the above copyright notice, 
		  this list of conditions and the following disclaimer.
	    ¥ Redistributions in binary form must reproduce the above copyright notice, 
		  this list of conditions and the following disclaimer in the documentation and/or 
		  other materials provided with the distribution.
	    ¥ Neither the name of the ColdSpring, ColdSpring AOP nor the names of its contributors may be used 
	      to endorse or promote products derived from this software without specific prior written permission.
	      
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
	OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
	OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
	POSSIBILITY OF SUCH DAMAGE.
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