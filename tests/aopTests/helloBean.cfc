<cfcomponent name="helloBean">

	<cffunction name="init" access="public" returntype="coldspring.tests.aopTests.helloBean" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="sayHello" access="public" returntype="string">
		<cfargument name="stuff" type="array" required="true" />
		<cfargument name="other" type="any" required="false" default="0" />
		<cfreturn "<b>Hello!</b><br/>" />
	</cffunction>

	<cffunction name="sayGoodbye" access="public" returntype="string">
		<cfargument name="stuff" type="array" required="true" />
		<cfargument name="other" type="any" required="false" />
		<cfreturn "<b>Goodbye!</b><br/>" />
	</cffunction>
	
</cfcomponent>