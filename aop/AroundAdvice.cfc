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

  $Id: AroundAdvice.cfc,v 1.3 2005/09/26 19:12:29 scottc Exp $
  $log$

---> 
 
<cfcomponent name="AroundAdvice" 
			displayname="AroundAdvice" 
			extends="coldspring.aop.Advice" 
			hint="Interface (Abstract Class) for Around Advice implimentations" 
			output="false">
			
	<cfset variables.adviceType = 'around' />
			
	<cffunction name="init" access="private" returntype="void" output="false">
		<cfthrow message="Abstract CFC. Cannot be initialized" />
	</cffunction>
	
	<cffunction name="around" access="public" returntype="any">
		<cfargument name="method" type="coldspring.aop.Method" required="true" />
		<cfargument name="args" type="struct" required="true" />
		<cfargument name="target" type="any" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
</cfcomponent>