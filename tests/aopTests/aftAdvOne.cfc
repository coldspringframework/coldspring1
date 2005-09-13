<cfcomponent name="aftAdvOne" extends="coldspring.aop.AfterReturningAdvice">
	
	<cfset variables.someData = 999 />
	
	<cffunction name="init" access="public" returntype="coldspring.tests.aopTests.aftAdvOne" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="afterReturning" access="public" returntype="any">
		<cfargument name="returnVal" type="any" required="true" />
		<cfargument name="method" type="coldspring.aop.Method" required="true" />
		<cfargument name="args" type="struct" required="true" />
		<cfargument name="target" type="any" required="true" />
		
		<cfreturn returnVal & "<br><br>Yall!!" />
		
	</cffunction>
	
	<cffunction name="setSomeData" access="public" returntype="void" output="false">
		<cfargument name="someData" type="numeric" required="true" />
		<cfset variables.someData = arguments.someData />
	</cffunction>
	
	<cffunction name="getSomeData" access="public" returntype="numeric" output="false">
		<cfreturn variables.someData />
	</cffunction>
	
</cfcomponent>