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

 $Id: MethodInterceptor.cfc,v 1.2 2005/10/07 13:13:13 scottc Exp $
 $log:$
	
---> 
 
<cfcomponent name="MethodInterceptor" 
			displayname="MethodInterceptor" 
			extends="coldspring.aop.Advice" 
			hint="Abstract Base Class for all Around Advice implimentations" 
			output="false">
			
	<cfset variables.adviceType = 'interceptor' />
			
	<cffunction name="init" access="private" returntype="void" output="false">
		<cfthrow message="Abstract CFC. Cannot be initialized" />
	</cffunction>
	
	<cffunction name="invokeMethod" access="public" returntype="any">
		<cfargument name="methodInvocation" type="coldspring.aop.MethodInvocation" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
</cfcomponent>