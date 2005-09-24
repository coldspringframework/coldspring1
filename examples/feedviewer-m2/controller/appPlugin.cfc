<cfcomponent extends="machii.framework.plugin">
	<!--- this plugin will announce the supplied rendering event after all other processing has completed  --->
	
	<cffunction name="postEvent" output="true">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="true" />
		<!--- this code will insert footer as applicable --->
	<!--- 	<cfoutput>
		#arguments.eventContext.getCurrentEvent().getName()#-#arguments.eventContext.hasNextEvent()#
		<cfdump var="#arguments.eventContext.getCurrentEvent().getArgs()#"/>
		<hr>
		</cfoutput>
		 --->
		<cfif not arguments.eventContext.hasNextEvent() and arguments.eventContext.getCurrentEvent().getName() neq getParameter('renderEventName','renderPage')>
			<cfset arguments.eventContext.announceEvent(getParameter('renderEventName','renderPage'),arguments.eventContext.getCurrentEvent().getArgs())/>
		</cfif>
	</cffunction> 


</cfcomponent>