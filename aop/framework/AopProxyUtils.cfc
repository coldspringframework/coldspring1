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

 $Id: AopProxyUtils.cfc,v 1.8 2005/10/10 18:40:10 scottc Exp $
 $Log: AopProxyUtils.cfc,v $
 Revision 1.8  2005/10/10 18:40:10  scottc
 Lots of fixes pertaining to returning and not returning values with afterAdvice, also added the security for method invocation that we discussed

 Revision 1.7  2005/10/09 22:45:25  scottc
 Forgot to add Dave to AOP license

	
---> 
 
<cfcomponent name="AopProxyUtils" 
			displayname="AopProxyUtils" 
			hint="Utilities for building Proxy Beans" 
			output="false">
			
	<cfset variables.logger = 0 />
			
	<cffunction name="init" access="public" returntype="coldspring.aop.framework.AopProxyUtils" output="false">
		<cfset var category = CreateObject("java", "org.apache.log4j.Category") />
		<cfset variables.logger = category.getInstance('coldspring.aop') />
		<cfset variables.logger.info("AopProxyUtils created") />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="clone" access="public" returntype="any" output="false" hint="creates a duplicate instance of an object">
		<cfargument name="obj" type="any" required="true" />
		<cfset var metaData = getMetaData(arguments.obj) />
		<cfset var objType = metaData.name />
		<cfset var functionIx = 0 />
		<cfset var function = '' />
		<cfset var property = '' />
		<cfset var propVal = '' />
		<cfset var target = CreateObject('component',objType) />
		<cfset var system = CreateObject('java','java.lang.System') />
		
		<cfif variables.logger.isInfoEnabled()>
			<cfset variables.logger.info("AopProxyUtils.clone() cloning object " & metaData.name) />
		</cfif>
		<!--- now we'll loop through the object's methods, if it's a setter and there's a getter, we'll call set on the
			  target with it --->
		<cfloop from="1" to="#arraylen(metaData.functions)#" index="functionIx">
			<cfset function = metaData.functions[functionIx].name />
			
			<!--- catch the init function --->
			<cfif function eq "init">
				<cfset target.init() />
				
			<cfelseif function.startsWith('set')>
				<cfset property = Right(function, function.length()-3) />
				<cftry>
					<cfinvoke component="#arguments.obj#"
						  method="get#property#" 
						  returnvariable="propVal">
					</cfinvoke>
					<cfinvoke component="#target#"
						  method="set#property#">
						  <cfinvokeargument name="#metaData.functions[functionIx].parameters[1].name#" value="#propVal#" />
					</cfinvoke>
					<cfcatch>
						<cfif variables.logger.isDebugEnabled()>
							<cfset variables.logger.error("[coldspring.aop.AspectCloneError] Error reading: Error setting property #property#, #cfcatch.Detail#") />
						</cfif>
						<cfthrow type="coldspring.aop.AspectCloneError" message="Error setting property #property#, #cfcatch.Detail#" />
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		
		<cfif variables.logger.isInfoEnabled()>
			<cfset variables.logger.info("AopProxyUtils.clone() created new object: " & objType & "@"& FormatBaseN(system.identityHashCode(target), 16) ) />
		</cfif>
		
		<cfreturn target />
	</cffunction>
	
	<cffunction name="createBaseProxyBean" access="public" returntype="any" output="false">
		<cfargument name="target" type="any" required="true" />
		<cfset var metaData = getMetaData(arguments.target) />
		<cfset var targetType = metaData.name />
		<cfset var path = GetDirectoryFromPath(getMetaData(this).path) />
		<cfset var tmpBean = "bean_" & REReplace(CreateUUID(),"[\W+]","","all")  />
		<cfset var beanDescription = '' />
		<cfset var proxyBean = 0 />
		
		<cfif variables.logger.isInfoEnabled()>
			<cfset variables.logger.info("AopProxyUtils.createBaseProxyBean() creating proxy for " & metaData.name) />
		</cfif>
		
		<!--- first load the AopProxyBean definition (the actual cfc file) --->
		<cftry>
			<cffile action="read" file="#path#/AopProxyBean.cfc" variable="beanDescription" />
			<cfcatch>
				<cfif variables.logger.isDebugEnabled()>
					<cfset variables.logger.error("[coldspring.aop.AopProxyError]: Error reading: #path#/AopProxyBean.cfc, #cfcatch.Detail#") />
				</cfif>
				<cfthrow type="coldspring.aop.AopProxyError" message="Error reading: #path#/AopProxyBean.cfc, #cfcatch.Detail#" />
			</cfcatch>
		</cftry>
		
		<!--- set the type for the proxy (extends) --->
		<cfset beanDescription = Replace(beanDescription, '${name}', 'coldspring.aop.framework.tmp.'&tmpBean, "ALL") />
		<cfset beanDescription = Replace(beanDescription, '${extends}', targetType, "ALL") />
		
		<!--- write it to disk, load it and delete it --->
		<cftry>
			<cffile action="write" file="#path#/tmp/#tmpBean#.cfc" output="#beanDescription#" />
			 <!--- import the file --->
			 <cfset proxyBean = CreateObject('component','coldspring.aop.framework.tmp.'&tmpBean).init(arguments.target) />
			 <!--- delete the file --->
			 <cffile action="delete" file="#path#/tmp/#tmpBean#.cfc" />
			 <cfcatch>
				<cfif variables.logger.isDebugEnabled()>
					<cfset variables.logger.error("[coldspring.aop.AopProxyError] Error reading: Error Loading: #tmpBean#, #cfcatch.Detail#") />
				</cfif>
			 	<cfthrow type="coldspring.aop.AopProxyError" message="Error Loading: #tmpBean#, #cfcatch.Detail#" />
			 </cfcatch>
		</cftry>
		
		<cfreturn proxyBean />
		
	</cffunction>
	
	<cffunction name="createUDF" access="public" returntype="void" output="false">
		<cfargument name="metaData" type="any" required="true" />
		<cfargument name="proxyObj" type="any" required="true" />
		
		<cfset var parameter = 0 />
		<cfset var paramIx = 0 />
		<cfset var function = '' />
		<cfset var path = GetDirectoryFromPath(getMetaData(this).path) />
		<cfset var tmpFunction = "fnct_" & REReplace(CreateUUID(),"[\W+]","","all") />
		<cfset var tmpFile = "tmp/" & tmpFunction & ".functions" />
		
		<cfif variables.logger.isInfoEnabled()>
			<cfset variables.logger.info("AopProxyUtils.createUDF() adding method " & metaData.name) />
		</cfif>
		
		<!--- <cfset var path = ExpandPath('coldspring.aop.framework.tmp') /> --->
		<!--- start method, but we'll use the uuid as the function name 
			  (to avoid namespace crashes with udfs in variables scope) --->
		<cfset function = "<cffunction name=""" & tmpFunction & """" />
		<cfif StructKeyExists(metaData,'access')>
			<cfset function = function & " access=""" & metaData.access & """" />
		</cfif>
		<cfif StructKeyExists(metaData,'returntype')>
			<cfset function = function & " returntype=""" & metaData.returntype & """" />
		<cfelse>
			<cfthrow type="coldspring.aop.BadProgrammingError" message="Not including a return type in cfc method declarations is considered bad practice and is not allowed by coldspring.aop !!" />
		</cfif>
		<cfif StructKeyExists(metaData,'output')>
			<cfset function = function & " output=""" & metaData.output & """" />
		</cfif>
		<cfset function = function & " > " & Chr(10) />
		
		<!--- add properties --->
		<cfloop from="1" to="#ArrayLen(metaData.parameters)#" index="paramIx">
			<cfset parameter = metaData.parameters[paramIx] />
			<cfset function = function & "<cfargument name=""" & parameter.name & """" />
			<cfif StructKeyExists(parameter,'type')>
				<cfset function = function & " type=""" & parameter.type & """" />
			</cfif>
			<cfif StructKeyExists(parameter,'required')>
				<cfset function = function & " required=""" & parameter.required & """" />
			</cfif>
			<cfif StructKeyExists(parameter,'default')>
				<cfset function = function & " default=""" & parameter.default & """" />
			</cfif>
			<cfset function = function & " /> " & Chr(10) />
		</cfloop>
		
		<!--- add method call --->
		<cfset function = function & "<cfset var rtn = callMethod('" & metaData.name & "', arguments) />" & Chr(10) />
		
		<!--- return a value if we need to --->
		<cfif not FindNoCase('void',metaData.returnType)>
			<cfset function = function & "<cfif isDefined('rtn')><cfreturn rtn /></cfif>" & Chr(10) />
		</cfif>
		<!--- close function --->
		<cfset function = function & "</cffunction>" />
		
		<!--- now try to write the function to the tmp file, load and delete it --->
		<cftry>
			<cffile action="write" file="#path#/#tmpFile#" output="#function#" />
			 <!--- import the file --->
			 <cfinclude template="#tmpFile#" /> 
			 <!--- delete the file --->
			 <cffile action="delete" file="#path#/#tmpFile#" />
			 <cfcatch>
				<cfif variables.logger.isDebugEnabled()>
					<cfset variables.logger.error("[coldspring.aop.UdfError] Error reading: Error Loading: #tmptmpFileBean#, #cfcatch.Detail#") />
				</cfif>
			 	<cfthrow type="coldspring.aop.UdfError" message="Error Loading: #tmpFile#, #cfcatch.Detail#" />
			 </cfcatch>
		</cftry>
		
		<!--- add function to the proxy Object --->
		<cfset arguments.proxyObj[metaData.name] = variables[tmpFunction] />
	</cffunction>
	
</cfcomponent>