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

  $Id: Method.cfc,v 1.5 2005/10/07 13:13:13 scottc Exp $
  $log:$

---> 
 
<cfcomponent name="Methood" 
			displayname="Methood" 
			hint="Base Class for Methods" 
			output="false">
			
	<cffunction name="init" access="public" returntype="coldspring.aop.Method" output="false">
		<cfargument name="target" type="any" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfargument name="args" type="struct" required="true" />
		
		<cfset variables.target = arguments.target />
		<cfset variables.method = arguments.method />
		<cfset variables.args = arguments.args />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="proceed" access="public" returntype="any" output="false" 
				hint="Executes captured method on target object">
				
		<cfset var rtn = 0 />
		
		<cfinvoke component="#variables.target#"
				  method="#variables.method#" 
				  argumentcollection="#variables.args#" 
				  returnvariable="rtn">
		</cfinvoke>	
		<cfif isDefined('rtn')>
			<cfreturn rtn />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getMethodName" access="public" returntype="string" output="false">
		<cfreturn variables.method />
	</cffunction>
	
</cfcomponent>