<!---
	 $Id: Method.cfc,v 1.2 2005/09/25 00:54:59 scottc Exp $
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
		<cfreturn variables.methdo />
	</cffunction>
	
</cfcomponent>