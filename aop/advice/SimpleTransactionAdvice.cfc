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

 $Id: SimpleTransactionAdvice.cfc,v 1.1 2009/02/26 22:56:36 mandelm Exp $
 $Log: SimpleTransactionAdvice.cfc,v $
 Revision 1.1  2009/02/26 22:56:36  mandelm
 Basic transaction advice for cf transactions.


--->

<cfcomponent hint="AOP Advice to wrap a method with a transaction, and escape the transaction, if we are already in one"
			extends="coldspring.aop.MethodInterceptor"
			output="false">

	<cffunction name="init" hint="Constructor" access="public" returntype="SimpleTransactionAdvice" output="false">
		<cfscript>
			setTransactionLocal(createObject("java", "java.lang.ThreadLocal").init());

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="invokeMethod" returntype="any" access="public" output="false" hint="invokes the method to be fired">
		<cfargument name="methodInvocation" type="coldspring.aop.MethodInvocation" required="true" hint="the method" />
		<cfset var local = {} />

		<cfif getInTransaction()>
			<cfset local.return = arguments.methodInvocation.proceed() />
		<cfelse>
				<cfset getTransactionLocal().set(true) />
				<cftry>
					<cftransaction>
						<cfset local.return = arguments.methodInvocation.proceed() />
					</cftransaction>

					<cfcatch>
						<cfset getTransactionLocal().set(false) />
						<cfrethrow>
					</cfcatch>
				</cftry>
			<cfset getTransactionLocal().set(false) />
		</cfif>
		<cfif StructKeyExists(local, "return")>
			<cfreturn local.return />
		</cfif>
	</cffunction>

	<cffunction name="getInTransaction" hint="returns if we are in a transaction" access="public" returntype="boolean" output="false">
		<cfscript>
			var local = StructNew();
			local.in = getTransactionLocal().get();

			if(NOT StructKeyExists(local, "in"))
			{
				getTransactionLocal().set(false);
				return getTransactionLocal().get();
			}

			return local.in;
		</cfscript>
	</cffunction>

	<cffunction name="getTransactionLocal" access="private" returntype="any" output="false">
		<cfreturn variables.transactionLocal />
	</cffunction>

	<cffunction name="setTransactionLocal" access="private" returntype="void" output="false">
		<cfargument name="transactionLocal" type="any" required="true">
		<cfset variables.transactionLocal = arguments.transactionLocal />
	</cffunction>

</cfcomponent>