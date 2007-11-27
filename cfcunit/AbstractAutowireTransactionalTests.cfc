<!---
 
  Copyright (c) 2005, David Ross, Chris Scott, Kurt Wiersma, Sean Corfield
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
		
			
 $Id: AbstractAutowireTransactionalTests.cfc,v 1.3 2007/11/27 05:08:14 scottc Exp $

--->

<cfcomponent displayname="AbstractAutowireTransactionalTests"
			 extends="coldspring.cfcunit.AbstractAutowireTests">
	
	<cfset variables.commit = false />
	
	<cffunction name="setUp" access="public" returntype="void" output="false">
		<cfset super.setUp() />
		<cftransaction action="begin"/>
	</cffunction>
	
	<cffunction name="tearDown" access="private" returntype="void" output="false">
		<cfif variables.commit>
			<cftransaction action="commit" />
		<cfelse>
			<cftransaction action="rollback" />
		</cfif>
		<cfset variables.commit = false />
		<cfset super.tearDown() />
	</cffunction>
	
	<cffunction name="setCommit" access="public" returntype="void" output="false">
		<cfargument name="commit" type="boolean" required="false" default="true" />
		<cfset variables.commit = arguments.commit />
	</cffunction>
	
</cfcomponent>