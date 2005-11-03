<cfcomponent name="InterceptorTests" 
			displayname="InterceptorTests" 
			hint="test interceptor methods" 
			extends="org.cfcunit.framework.TestCase">

	<cffunction name="setUp" access="private" returntype="void" output="false">
		<cfset variables.sys = CreateObject('java','java.lang.System') />
	</cffunction>
	
	<cffunction name="testBeforeInterceptor" access="public" returntype="void" output="false">
		<cfset var testObj = CreateObject('component','coldspring.tests.aopTests.badBean').init() />
		<cfset var method = CreateObject('component','coldspring.aop.Method') />
		<cfset var invocation = CreateObject('component','coldspring.aop.MethodInvocation') />
		<cfset var beforeAdvice = CreateObject('component','coldspring.tests.aopTests.beforeAdvice').init() />
		<cfset var beforeAdviceInterceptor = CreateObject('component','coldspring.aop.BeforeAdviceInterceptor') />
		<cfset method.init(testObj, 'doGoodMethod', StructNew()) />
		<cfset invocation.init(method, StructNew(), testObj) />
		<cfset beforeAdviceInterceptor.init(beforeAdvice) />
		
		<cftry>
			<cfset beforeAdviceInterceptor.invokeMethod(invocation) />
			<cfcatch>
				<cfset ex = CreateObject("component", "coldspring.aop.Exception").init(cfcatch) />
				<cfset variables.sys.out.println("TYPE: " & ex.getType()) />
				<cfset variables.sys.out.println("MESSAGE: " & ex.getMessage()) />
			</cfcatch>
		</cftry>
		
	</cffunction>
	
	<cffunction name="testAfterInterceptor" access="public" returntype="void" output="false">
		<cfset var testObj = CreateObject('component','coldspring.tests.aopTests.badBean').init() />
		<cfset var method = CreateObject('component','coldspring.aop.Method') />
		<cfset var invocation = CreateObject('component','coldspring.aop.MethodInvocation') />
		<cfset var afterAdvice = CreateObject('component','coldspring.tests.aopTests.afterAdvice').init() />
		<cfset var afterAdviceInterceptor = CreateObject('component','coldspring.aop.AfterReturningAdviceInterceptor') />
		<cfset method.init(testObj, 'doGoodMethod', StructNew()) />
		<cfset invocation.init(method, StructNew(), testObj) />
		<cfset afterAdviceInterceptor.init(afterAdvice) />
		
		<cftry>
			<cfset afterAdviceInterceptor.invokeMethod(invocation) />
			<cfcatch>
				<cfset ex = CreateObject("component", "coldspring.aop.Exception").init(cfcatch) />
				<cfset variables.sys.out.println("TYPE: " & ex.getType()) />
				<cfset variables.sys.out.println("MESSAGE: " & ex.getMessage()) />
			</cfcatch>
		</cftry>
		
	</cffunction>

</cfcomponent>