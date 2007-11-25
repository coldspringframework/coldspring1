<cfcomponent name="TransactionAdvice" 
			 extends="coldspring.aop.MethodInterceptor">
	
	<cffunction name="invokeMethod" access="public" returntype="any">
		<cfargument name="mi" type="coldspring.aop.MethodInvocation" required="true" />
		<cfset var target = arguments.mi.getTarget() />
		<cfset var commit = false />
		<cfset var rtn = 0 />
		<cfset var sys = CreateObject('java','java.lang.System') />
		
		<cftransaction action="begin">
			<cfset sys.out.println("BEGINING TRANSACTION...")>
			<cfset rtn =  arguments.mi.proceed() />
			<!--- get the commit flag on the target object (if we can) --->
			<cftry>
				<cfset commit = target.getCommit() />
				<cfcatch></cfcatch>
			</cftry>
			
			<cfif commit>
				<cfset sys.out.println("COMMITTING TRANSACTION...")>
				<cftransaction action="commit" />
			<cfelse>
				<cfset sys.out.println("ROLLING BACK TRANSACTION...")>
				<cftransaction action="rollback" />
			</cfif>
			<cfset sys.out.println("ENDING TRANSACTION...")>
		</cftransaction>
		
		<!--- reset the commit flag on the target object (if we can) --->
		<cftry>
			<cfset commit = target.setCommit(false) />
			<cfcatch></cfcatch>
		</cftry>
		
		<cfif isDefined("rtn")>
			<cfreturn rtn />
		</cfif>
		
	</cffunction>
	
</cfcomponent>