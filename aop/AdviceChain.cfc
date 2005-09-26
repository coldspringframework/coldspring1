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

 $Id: AdviceChain.cfc,v 1.3 2005/09/26 15:48:12 scottc Exp $
 $log$
	
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