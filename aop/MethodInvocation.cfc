<!---
	  
  Copyright (c) 2005, Chris Scott, David Ross
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

 $Id: MethodInvocation.cfc,v 1.3 2005/10/09 22:45:24 scottc Exp $
 $Log: MethodInvocation.cfc,v $
 Revision 1.3  2005/10/09 22:45:24  scottc
 Forgot to add Dave to AOP license

	
---> 
 
<cfcomponent name="MethodInvocation" 
			displayname="MethodInvocation" 
			hint="Base Class for Method Invokation, joinpoint for Method Interceptors" 
			output="false">
			
	<cffunction name="init" access="public" returntype="coldspring.aop.MethodInvocation" output="false">
		<cfargument name="method" type="coldspring.aop.Method" required="true" />
		<cfargument name="args" type="struct" required="true" />
		<cfargument name="target" type="any" required="true" />
		
		<cfset variables.method = arguments.method />
		<cfset variables.args = arguments.args />
		<cfset variables.target = arguments.target />
		<cfif StructKeyExists(arguments,"methodInterceptor")>
			<cfset variables.methodInterceptor = arguments.methodInterceptor />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="proceed" access="public" returntype="any">
		<cfset var rtn = 0 />
		<!--- continue with interceptor chain or call method to proceed --->
		<cfif StructKeyExists(variables,"methodInterceptor")>
			<cfset rtn = variables.methodInterceptor.invokeMethod(variables.nextInvocation) />
		<cfelse>
			<cfset rtn = variables.method.proceed() />
		</cfif>
		<cfif isDefined('rtn')>
			<cfreturn rtn />
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
	
	<cffunction name="setInterceptor" access="public" returntype="void" output="false">
		<cfargument name="methodInterceptor" type="coldspring.aop.MethodInterceptor" required="false" />
		<cfargument name="nextInvocation" type="coldspring.aop.MethodInvocation" required="false" />
		<cfset variables.methodInterceptor = arguments.methodInterceptor />
		<cfset variables.nextInvocation = arguments.nextInvocation />
	</cffunction>
	
</cfcomponent>