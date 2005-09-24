<!---
	 $Id: BeanReference.cfc,v 1.1 2005/09/24 16:44:16 rossd Exp $
---> 

<cfcomponent>

	<cffunction name="init" returntype="coldspring.beans.BeanReference" access="public" output="false">
		<cfargument name="beanID" type="string" required="true" />
		<cfset this.beanID = arguments.beanID/>		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getBeanID" returntype="string" access="public" output="false">
		<cfreturn this.beanID />		
	</cffunction>
</cfcomponent>

