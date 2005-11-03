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

 $Id: ThrowsAdviceInterceptor.cfc,v 1.1 2005/11/03 02:09:22 scottc Exp $
 $Log: ThrowsAdviceInterceptor.cfc,v $
 Revision 1.1  2005/11/03 02:09:22  scottc
 Initial classes to support throwsAdvice, as well as implementing interceptors to make before and after advice (as well as throws advice) all part of the method invocation chain. This is very much in line with the method invocation used in Spring, seems very necessary for throws advice to be implemented. Also should simplify some issues with not returning null values. These classes are not yet implemented in the AopProxyBean, so nothing works yet!


---> 
 
<cfcomponent name="ThrowsAdviceInterceptor" 
			displayname="ThrowsAdviceInterceptor" 
			extends="coldspring.aop.Advice" 
			hint="Interceptor for handling Throws Advice" 
			output="false">
			
	<cfset variables.adviceType = 'throws' />
			
	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="throwsAdvice" type="coldspring.aop.ThrowsAdvice" required="true" />
		<cfset variables.throwsAdvice = arguments.throwsAdvice />
	</cffunction>
	
	<cffunction name="invokeMethod" access="public" returntype="any">
		<cfargument name="methodInvocation" type="coldspring.aop.MethodInvocation" required="true" />
		<cfset var rtn = 0 />
		<cfset var ex = 0 />
		<cftry>
			<cfreturn arguments.methodInvocation.proceed()>
			<cfcatch>
				<cfif isExceptionType(cfcatch.Type)>
					<cfset ex = CreateObject("component", "coldspring.aop.Exception").init(cfcatch) />
					<cfset variables.throwsAdvice.afterThrowing(arguments.methodInvocation.getMethod(),
						   	arguments.methodInvocation.getArguments(),
							arguments.methodInvocation.getTarget(),
							ex) />
				</cfif>
				<cfrethrow />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="isExceptionType" access="private" returntype="boolean" output="false">
		<cfargument name="exceptionType" type="string" required="true" />
		<cfif (LCase(variables.throwsAdvice.getExceptionType()) IS 'any') OR
			  (LCase(arguments.exceptionType).startsWith(LCase(variables.throwsAdvice.getExceptionType())))>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
</cfcomponent>