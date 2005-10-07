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

  $Id: BeforeAdvice.cfc,v 1.4 2005/10/07 13:13:13 scottc Exp $
  $log:$

---> 
 
<cfcomponent name="BeforeAdvice" 
			displayname="BeforeAdvice" 
			extends="coldspring.aop.Advice" 
			hint="Interface (Abstract Class) for Before Advice implimentations" 
			output="false">
			
	<cfset variables.adviceType = 'before' />
			
	<cffunction name="init" access="private" returntype="void" output="false">
		<cfthrow message="Abstract CFC. Cannot be initialized" />
	</cffunction>
	
	<cffunction name="before" access="public" returntype="any">
		<cfargument name="method" type="coldspring.aop.Method" required="true" />
		<cfargument name="args" type="struct" required="true" />
		<cfargument name="target" type="any" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
</cfcomponent>