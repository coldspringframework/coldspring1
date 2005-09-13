<!---
	 $Id: AopProxyUtils.cfc,v 1.1 2005/09/13 17:01:53 scottc Exp $
	 $log$
	
	Copyright (c) 2005, Chris Scott
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without modification, 
	are permitted provided that the following conditions are met:
	
	    ¥ Redistributions of source code must retain the above copyright notice, 
		  this list of conditions and the following disclaimer.
	    ¥ Redistributions in binary form must reproduce the above copyright notice, 
		  this list of conditions and the following disclaimer in the documentation and/or 
		  other materials provided with the distribution.
	    ¥ Neither the name of the ColdSpring, ColdSpring AOP nor the names of its contributors may be used 
	      to endorse or promote products derived from this software without specific prior written permission.
	      
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
	OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
	OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
	POSSIBILITY OF SUCH DAMAGE.
---> 
 
<cfcomponent name="AopProxyUtils" 
			displayname="AopProxyUtils" 
			hint="Utilities for building Proxy Beans" 
			output="false">
			
	<cffunction name="init" access="public" returntype="coldspring.aop.framework.AopProxyUtils" output="false">
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
		
		<!--- now we'll loop through the object's methods, if it's a setter and there's a getter, we'll call set on the
			  target with it --->
		<cfloop from="1" to="#arraylen(metaData.functions)#" index="functionIx">
			<cfset function = metaData.functions[functionIx].name />
			<cfif function.startsWith('set')>
				<cfset property = Right(function, function.length()-3) />
				<cftry>
					<cfinvoke component="#arguments.obj#"
						  method="get#property#" 
						  returnvariable="propVal">
					</cfinvoke>	
					<cfinvoke component="#target#"
						  method="set#property#" 
						  returnvariable="propertyVal">
						  <cfinvokeargument name="#property#" value="#propVal#" />
					</cfinvoke>	
					<cfcatch>
						<cfthrow type="coldspring.aop.AspectCloneError" message="Error setting property #property#, #cfcatch.Detail#" />
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		
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
		
		<!--- first load the AopProxyBean definition (the actual cfc file) --->
		<cftry>
			<cffile action="read" file="#path#/AopProxyBean.cfc" variable="beanDescription" />
			<cfcatch>
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
			<cfset function = function & "<cfreturn rtn /> " & Chr(10) />
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
			 	<cfthrow type="coldspring.aop.UdfError" message="Error Loading: #tmpFile#, #cfcatch.Detail#" />
			 </cfcatch>
		</cftry>
		
		<!--- add function to the proxy Object --->
		<cfset arguments.proxyObj[metaData.name] = variables[tmpFunction] />
	</cffunction>
	
</cfcomponent>