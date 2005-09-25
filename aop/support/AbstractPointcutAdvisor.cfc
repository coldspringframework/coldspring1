<!---
	 $Id: AbstractPointcutAdvisor.cfc,v 1.2 2005/09/25 00:54:59 scottc Exp $
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
 
<cfcomponent name="AbstractPointcutAdvisor" 
			displayname="AbstractPointcutAdvisor" 
			extends="coldspring.aop.Advisor"
			hint="Abstract Base Class for Pointcut Advisor implimentations" 
			output="false">
			
	<cfset variables.order = 999 />
	<cfset variables.advice = 0 />
			
	<cffunction name="init" access="private" returntype="void" output="false">
		<cfthrow message="Abstract CFC. Cannot be initialized" />
	</cffunction>
	
	<cffunction name="setOrder" access="public" returntype="void" output="false">
		<cfargument name="order" type="numeric" required="true" />
		<cfset variables.order = arguments.order />
	</cffunction>
	
	<cffunction name="getOrder" access="public" returntype="numeric" output="false">
		<cfreturn variables.order />
	</cffunction>
	
	<cffunction name="setAdvice" access="public" returntype="void" output="false">
		<cfargument name="advice" type="coldspring.aop.Advice" required="true" />
		<cfset variables.advice = arguments.advice />
	</cffunction>
	
	<cffunction name="getAdvice" access="public" returntype="coldspring.aop.Advice" output="false">
		<cfreturn variables.advice />
	</cffunction>
	
</cfcomponent>