<!---
	 $Id: NamedMethodPointcut.cfc,v 1.3 2005/09/25 17:37:47 scottc Exp $
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
 
<cfcomponent name="NamedMethodPointcutAdvisor" 
			displayname="NamedMethodPointcutAdvisor" 
			extends="coldspring.aop.Pointcut" 
			hint="Pointcut to match method names (with wildcard)" 
			output="false">
			
	<cfset variables.mappedNames = 0 />
	
	<cffunction name="init" access="public" returntype="coldspring.aop.support.NamedMethodPointcut" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setMappedName" access="public" returntype="void" output="false">
		<cfargument name="mappedName" type="string" required="true" />
		<cfset setMappedNames(arguments.mappedName) />
	</cffunction>
	
	<cffunction name="setMappedNames" access="public" returntype="void" output="false">
		<cfargument name="mappedNames" type="string" required="true" />
		<cfset var name = '' />
		<cfset variables.mappedNames = ArrayNew(1) />
		<cfloop list="#arguments.mappedNames#" index="name">
			<cfset ArrayAppend(variables.mappedNames, name) />
		</cfloop>
	</cffunction>
	
	<cffunction name="matches" access="public" returntype="boolean" output="true">
		<cfargument name="methodName" type="string" required="true" />
		<cfset var mappedName = '' />
		<cfset var ix = 0 />
		<cfloop from="1" to="#ArrayLen(variables.mappedNames)#" index="ix">
			<cfset mappedName = variables.mappedNames[ix] />
			<cfif (arguments.methodName EQ mappedName) OR
				  isMatch(arguments.methodName, mappedName) >
				<cfreturn true />	  
			</cfif>
		</cfloop>
		<cfreturn false />
	</cffunction>
			
	<cffunction name="isMatch" access="private" returntype="boolean" output="true">
		<cfargument name="methodName" type="string" required="true" />
		<cfargument name="mappedName" type="string" required="true" />
		<cfif mappedName EQ "*">
			<cfreturn true />
		<cfelseif mappedName.startsWith('*')>
			<cfreturn methodName.endsWith(Right(mappedName,mappedName.length()-1)) />
		<cfelseif mappedName.endsWith('*')>
			<cfreturn methodName.startsWith(Left(mappedName, mappedName.length()-1)) />
		</cfif>
		<cfreturn false />
	</cffunction>
				
</cfcomponent>