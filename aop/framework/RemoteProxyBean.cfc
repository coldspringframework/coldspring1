<!---
	  
  Copyright (c) 2005, Chris Scott, David Ross, Kurt Wiersma, Sean Corfield
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

 $Id: RemoteProxyBean.cfc,v 1.1 2006/01/13 15:00:12 scottc Exp $
 $Log: RemoteProxyBean.cfc,v $
 Revision 1.1  2006/01/13 15:00:12  scottc
 CSP-38 - First pass at RemoteProxyBean, creating remote services for CS managed seriveces through AOP

	
---> 
 
<cfcomponent name="${name}" 
			displayname="${name}:RemoteProxyBean" 
			hint="Abstract Base Class for Aop Based Remote Proxy Beans" 
			output="false">
	
	<cfset variables.beanFactoryName = "${contextName}" />
	<cfset variables.beanFactoryScope = "${scope}" />
	<cfset setup() />
	
	<cffunction name="setup" access="public" returntype="void">
		<cfset var appContextUtils = 0 />
		<cfset var appContext = 0 />
		<cfset var remoteFactory = 0 />
		<!--- make sure scope is setup (could have been set to '', meaning application, default) --->
		<cfif not len(variables.beanFactoryScope)>
			<cfset variables.beanFactoryScope = 'application' />
		</cfif>
		<cftry>		
			<cfset appContextUtils = createObject("component","coldspring.context.util.ApplicationContextUtils").init()/>
			<cfif not len(variables.beanFactoryName)>
				<cfset appContext = appContextUtils.getDefaultApplicationContext(variables.beanFactoryScope) />
			<cfelse>
				<cfset appContext = appContextUtils.getNamedApplicationContext(variables.beanFactoryScope,
					   																variables.beanFactoryName) />
			</cfif>
			<cfset remoteFactory = appContext.getBean("&${proxyFactoryId}") />
			<cfset variables.target = appContext.getBean("${proxyFactoryId}") />
			<cfset variables.adviceChains = remoteFactory.getProxyAdviceChains() />
			
			<!--- so we can dump and see out data members --->
			<cfset this.target = variables.target />
			<cfset this.adviceChains = variables.adviceChains />
			<cfcatch>
				<cfdump var="#cfcatch#" /><cfabort />
				<cfthrow type="coldspring.remoting.ApplicationContextError" 
						 message="Sorry, a ColdSpring ApplicationContext named ${contextName} was not found in ${scope} scope. Please make sure your context is properly loaded. Perhapse your main application is not running?" />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="callMethod" access="public" returntype="any">
		<cfargument name="methodName" type="string" required="true" />
		<cfargument name="args" type="struct" required="true" />
		<cfset var adviceChain = 0 />
		<cfset var methodInvocation = 0 />
		<cfset var rtn = 0 />
		<cfset var method = 0 />
		
		<!--- if an advice chain was created for this method, retrieve a methodInvocation chain from it and proceed --->
		<cfif StructKeyExists(variables.adviceChains, arguments.methodName)>
			<cfset method = CreateObject('component','coldspring.aop.Method').init(variables.target, arguments.methodName, arguments.args) />
			<cfset adviceChain = variables.adviceChains[arguments.methodName] />
			<cfset methodInvocation = adviceChain.getMethodInvocation(method, arguments.args, variables.target) />
			<cfreturn methodInvocation.proceed() />
		<cfelse>
			<!--- if there's no advice chains to execute, just call the method --->
			<cfinvoke component="#variables.target#"
					  method="#arguments.methodName#" 
					  argumentcollection="#arguments.args#" 
					  returnvariable="rtn">
			</cfinvoke>
			<cfif isDefined('rtn')>
				<cfreturn rtn />
			</cfif>
		</cfif>
		
	</cffunction>
			
	${functions}
	
</cfcomponent>