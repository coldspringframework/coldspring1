<cfcomponent name="badBean">

	<cffunction name="init" access="public" returntype="coldspring.tests.aopTests.badBean" output="false">
		<cfset variables.sys = CreateObject('java','java.lang.System') />
		<cfreturn this />
	</cffunction>

	<cffunction name="doBadMethod" access="public" returntype="void">
		<cfset var result = 0 />
		<cfset variables.sys.out.println('') />
		<cfset variables.sys.out.println("I'm gonna devide by 0!") />
		<cfset result = 10 / 0 />
	</cffunction>

	<cffunction name="doGoodMethod" access="public" returntype="numeric">
		<cfset var result = 0 />
		<cfset variables.sys.out.println('') />
		<cfset variables.sys.out.println("I'm gonna devide by 2!") />
		<cfset result = 10 / 2 />
		<cfreturn result />
	</cffunction>
	
</cfcomponent>