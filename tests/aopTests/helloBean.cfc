<cfcomponent name="helloBean">

	<cffunction name="init" access="public" returntype="coldspring.tests.aopTests.helloBean" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="sayHello" access="public" returntype="string">
		<cfargument name="inputString" type="string" required="true" />
		<cfreturn arguments.inputString & "<b>Hello!</b><br/>" />
	</cffunction>

	<cffunction name="sayGoodbye" access="public" returntype="string">
		<cfargument name="inputString" type="string" required="true" />
		<cfreturn arguments.inputString & "<b>Goodbye!</b><br/>" />
	</cffunction>
	
</cfcomponent>