
<cfif not structKeyExists(request,'event')>
	<cfset request.event = createObject("component","coldspring.examples.feedviewer-fb4.plugins.event").init()/>
</cfif>
<cfif structKeyExists(request,'eventArgs') and isStruct(request.eventArgs)>
	<cfloop collection="#request.eventArgs#" item="a">
		<cfset request.event.setArg(a,request.eventArgs[a])/>
	</cfloop>
</cfif>
<cfloop collection="#attributes#" item="a">
		<cfset request.event.setArg(a,attributes[a])/>
	</cfloop>
<cfset event = request.event/>

