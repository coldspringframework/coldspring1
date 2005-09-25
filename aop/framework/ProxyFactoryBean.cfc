<!---
	 $Id: ProxyFactoryBean.cfc,v 1.3 2005/09/25 00:55:00 scottc Exp $
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
 
<cfcomponent name="ProxyFactoryBean" 
			displayname="ProxyFactoryBean" 
			extends="coldspring.beans.factory.FactoryBean"
			hint="Concrete Class for ProxyFactoryBean" 
			output="false">
	
	<cfset variables.singleton = true />		
	<cfset variables.advisorChain = ArrayNew(1) />
	<cfset variables.interceptorNames = 0 />
	<cfset variables.aopProxyUtils = CreateObject('component','coldspring.aop.framework.aopProxyUtils').init() />
	<cfset variables.proxyObject = 0 />
	<cfset variables.constructed = false />
			
	<cffunction name="init" access="public" returntype="coldspring.aop.framework.ProxyFactoryBean" output="false">
		<cfset var category = CreateObject("java", "org.apache.log4j.Category") />
		<cfset variables.logger = category.getInstance('coldspring.aop') />
		<cfset variables.logger.info("ProxyFactoryBean created") />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setTarget" access="public" returntype="void" output="false">
		<cfargument name="target" type="any" required="true" />
		<cfset variables.target = arguments.target />	
	</cffunction>
	
	<cffunction name="setInterceptorNames" access="public" returntype="void" output="false">
		<cfargument name="interceptorNames" type="array" required="true" />
		<cfset variables.interceptorNames = arguments.interceptorNames />
	</cffunction>
	
	<cffunction name="addAdvisor" access="public" returntype="string" output="false">
		<cfargument name="advisor" type="coldspring.aop.Advisor" required="true"/>
		<cfset ArrayAppend(variables.advisorChain, arguments.advisor) />
	</cffunction>
	
	<cffunction name="getBeanFactory" access="public" output="false" returntype="struct" 
				hint="I retrieve the Bean Factory from this instance's data">
		<cfreturn variables.BeanFactory />
	</cffunction>

	<cffunction name="setBeanFactory" access="public" output="false" returntype="void"  
				hint="I set the Bean Factory in this instance's data">
		<cfargument name="beanFactory" type="coldspring.beans.BeanFactory" required="true"/>
		<cfset variables.BeanFactory = arguments.beanFactory />
	</cffunction>
	
	<cffunction name="getObjectType" access="public" returntype="string" output="false">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="isSingleton" access="public" returntype="boolean" output="false">
		<cfreturn variables.singleton />
	</cffunction>

	<cffunction name="setSingleton" access="public" output="false" returntype="void">
		<cfargument name="singleton" type="boolean" required="true"/>
		<cfset variables.singleton = arguments.singleton />
	</cffunction>
	
	<cffunction name="isConstructed" access="public" returntype="boolean" output="false">
		<cfreturn variables.constructed />
	</cffunction>
	
	<cffunction name="getObject" access="public" returntype="any" output="true">
		<cfif isSingleton()>
			<cfif not isConstructed()>
				<cfset variables.logger.info("ProxyFactoryBean.getObject() creating new proxy instance") />
				<cfreturn createProxyInstance() />
			<cfelse>
				<cfset variables.logger.info("ProxyFactoryBean.getObject() returning cached proxy instance") />
				<cfreturn variables.proxyObject />
			</cfif>
		<cfelse>
			<cfthrow type="Method.NotImplemented" message="Creating non-singleton proxies is not yet supported!">
		</cfif>
	</cffunction>
	
	<cffunction name="createProxyInstance" access="private" returntype="any" output="true">
		<cfset var methodAdviceChains = StructNew() />
		<cfset var md = getMetaData(variables.target)/>
		<cfset var functionIx = 0 />
		<cfset var functionName = '' />
		<cfset var advisorIx = 0 />
		<cfset var createInterceptMethod = false />
		<cfset var aopProxyBean = variables.aopProxyUtils.createBaseProxyBean(variables.target) />
		<!--- <cfset var aopProxyBean = CreateObject('component','coldspring.aop.framework.AopProxyBean').init(variables.target) /> --->
		
		<!--- first we need to build the advisor chain to search for pointcut matches --->
		<cfset buildAdvisorChain() />
		
		<!--- now we'll loop through the target's methods and search for advice to add to the advice chain --->
		<cfloop from="1" to="#arraylen(md.functions)#" index="functionIx">
		
			<cfset functionName = md.functions[functionIx].name />
			
			<cfif not ListFindNoCase('init', functionName)>
				<cfloop from="1" to="#ArrayLen(variables.advisorChain)#" index="advisorIx">
					<cfif variables.advisorChain[advisorIx].matches(functionName)>
						<!--- if we found a mathing pointcut in an advisor, make sure this method has an adviceChain started --->
						<cfif not StructKeyExists(methodAdviceChains, functionName)>
							<cfset methodAdviceChains[functionName] = CreateObject('component','coldspring.aop.AdviceChain').init() />
						</cfif>
						<!--- and duplicate the advice to this method's advice chain --->
						<cfset methodAdviceChains[functionName].addAdvice(
							   variables.aopProxyUtils.clone(variables.advisorChain[advisorIx].getAdvice()) ) />
					</cfif>
				</cfloop>
				
				<!--- so here's where we'll inject intercept methods --->
				<cfset variables.aopProxyUtils.createUDF(md.functions[functionIx], aopProxyBean) />
			</cfif>
			
		</cfloop>
		
		<!--- now give the proxy object the advice chains --->
		<cfset aopProxyBean.setAdviceChains(methodAdviceChains) />
		
		<!--- store the proxyObject --->
		<cfset variables.proxyObject = aopProxyBean />
		<cfset variables.constructed = true />
		
		<cfreturn aopProxyBean />
		
	</cffunction>
			
	<cffunction name="buildAdvisorChain" access="private" returntype="void" output="false">
		<cfset var advisor = 0 />
		<cfset var ix = 0 />
		<cfif isArray(variables.interceptorNames)>
			<cfloop from="1" to="#ArrayLen(variables.interceptorNames)#" index="ix">
				<cfif variables.logger.isInfoEnabled()>
					<cfset variables.logger.info("ProxyFactoryBean.getObject() buildAdvisorChain adding Advisor: " & variables.interceptorNames[ix]) />
				</cfif>
				<cfset ArrayAppend(variables.advisorChain, getBeanFactory().getBean(variables.interceptorNames[ix])) />
			</cfloop>
		</cfif>
	</cffunction>	
	
</cfcomponent>