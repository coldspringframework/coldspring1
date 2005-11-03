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

 $Id: BeforeAdviceInterceptor.cfc,v 1.1 2005/11/03 02:09:22 scottc Exp $
 $Log: BeforeAdviceInterceptor.cfc,v $
 Revision 1.1  2005/11/03 02:09:22  scottc
 Initial classes to support throwsAdvice, as well as implementing interceptors to make before and after advice (as well as throws advice) all part of the method invocation chain. This is very much in line with the method invocation used in Spring, seems very necessary for throws advice to be implemented. Also should simplify some issues with not returning null values. These classes are not yet implemented in the AopProxyBean, so nothing works yet!

 Revision 1.3  2005/10/09 22:45:24  scottc
 Forgot to add Dave to AOP license

	
---> 
 
<cfcomponent name="BeforeAdviceInterceptor" 
			displayname="BeforeAdviceInterceptor" 
			extends="coldspring.aop.Advice" 
			hint="Interceptor for handling Before Advice" 
			output="false">
			
	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="beforeAdvice" type="coldspring.aop.BeforeAdvice" required="true" />
		<cfset variables.beforeAdvice = arguments.beforeAdvice />
	</cffunction>
	
	<cffunction name="invokeMethod" access="public" returntype="any">
		<cfargument name="methodInvocation" type="coldspring.aop.MethodInvocation" required="true" />
		<cfset variables.beforeAdvice.before(arguments.methodInvocation.getMethod(),
						   	arguments.methodInvocation.getArguments(),
							arguments.methodInvocation.getTarget() ) />
		<cfreturn arguments.methodInvocation.proceed()>
	</cffunction>
	
</cfcomponent>