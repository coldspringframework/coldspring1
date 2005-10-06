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

 $Id: MethodInvocation.cfc,v 1.1 2005/10/06 13:11:20 scottc Exp $
 $log$
	
---> 
 
<cfcomponent name="MethodInvocation" 
			displayname="MethodInvocation" 
			hint="Base Class for Method Invokation, joinpoint for Method Interceptors" 
			output="false">
			
	<cffunction name="init" access="public" returntype="coldspring.aop.MethodInvocation" output="false">
		<cfargument name="method" type="coldspring.aop.Method" required="true" />
		<cfargument name="args" type="struct" required="true" />
		<cfargument name="target" type="any" required="true" />
		<cfargument name="methodInterceptor" type="coldspring.aop.MethodInvocation" required="false" />
		
		<cfset variables.method = arguments.method />
		<cfset variables.args = arguments.args />
		<cfset variables.target = arguments.target />
		<cfif StructKeyExists(arguments,"methodInterceptor")>
			<cfset variables.methodInterceptor = arguments.methodInterceptor />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="proceed" access="public" returntype="any">
		<!--- continue with interceptor chain or call method to proceed --->
		<cfif StructKeyExists(variables,"methodInterceptor")>
			<cfset variables.methodInterceptor.invoke() />
		<cfelse>
			<cfset variables.method.proceed() />
		</cfif>
	</cffunction>
	
	<cffunction name="getMethod" access="public" returntype="coldspring.aop.Method" output="false">
		<cfreturn variables.method />
	</cffunction>
	
	<cffunction name="getArguments" access="public" returntype="struct" output="false">
		<cfreturn variables.args />
	</cffunction>
	
	<cffunction name="getTarget" access="public" returntype="struct" output="false">
		<cfreturn variables.target />
	</cffunction>
	
</cfcomponent>