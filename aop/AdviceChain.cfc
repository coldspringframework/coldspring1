<!---
	 $Id: AdviceChain.cfc,v 1.2 2005/09/25 00:54:59 scottc Exp $
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
 
<cfcomponent name="AdviceChain" 
			displayname="AdviceChain" 
			hint="Base Class for all Advice Chains" 
			output="false">
			
	<cffunction name="init" access="public" returntype="coldspring.aop.AdviceChain" output="false">
		<cfset variables.beforeAdvice = ArrayNew(1) />
		<cfset variables.afterAdvice = ArrayNew(1) />
		<cfset variables.aroundAdvice = ArrayNew(1) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="addAdvice" access="public" returntype="void" output="false">
		<cfargument name="advice" type="coldspring.aop.Advice" required="true" />
		<cfswitch expression="#advice.getType()#">
			<cfcase value="before">
				<cfset ArrayAppend(variables.beforeAdvice, arguments.advice) />
			</cfcase>
			<cfcase value="afterReturning">
				<cfset ArrayAppend(variables.afterAdvice, arguments.advice) />
			</cfcase>
			<cfcase value="around">
				<cfif ArrayLen(variables.aroundAdvice) GT 0>
					<cfthrow type="coldspring.aop.MalformedAviceException" message="There can only be one around advice declared for each method!" />
				<cfelse>
					<cfset ArrayAppend(variables.aroundAdvice, arguments.advice) />
				</cfif>
			</cfcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="getAdvice" access="public" returntype="Array" output="false">
		<cfargument name="adviceType" type="string" required="true" />
		<cfswitch expression="#arguments.adviceType#">
			<cfcase value="before">
				<cfreturn variables.beforeAdvice />
			</cfcase>
			<cfcase value="afterReturning">
				<cfreturn variables.afterAdvice />
			</cfcase>
			<cfcase value="around">
				<cfreturn variables.aroundAdvice />
			</cfcase>
		</cfswitch>
	</cffunction>
	
</cfcomponent>