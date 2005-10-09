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

 $Id: DefaultPointcutAdvisor.cfc,v 1.5 2005/10/09 22:45:24 scottc Exp $
 $Log: DefaultPointcutAdvisor.cfc,v $
 Revision 1.5  2005/10/09 22:45:24  scottc
 Forgot to add Dave to AOP license

	
---> 
 
<cfcomponent name="DefaultPointcutAdvisor" 
			displayname="DefaultPointcutAdvisor" 
			extends="coldspring.aop.support.AbstractPointcutAdvisor" 
			hint="Abstract Base Class for Pointcut Advisor implimentations" 
			output="false">
			
	<cfset variables.pointcut = 0 />
			
	<cffunction name="init" access="public" returntype="coldspring.aop.DefaultPointcutAdvisor" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setPointcut" access="public" returntype="void" output="false">
		<cfargument name="pointcut" type="coldspring.aop.Pointcut" required="true" />
		<cfset variables.pointcut = arguments.pointcut />
	</cffunction>
	
	<cffunction name="getPointcut" access="public" returntype="coldspring.aop.Pointcut" output="false">
		<cfreturn variables.pointcut />
	</cffunction>
	
</cfcomponent>