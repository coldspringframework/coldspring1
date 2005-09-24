<cfsilent>
<cfif FindNoCase(".xml.cfm", GetFileFromPath(GetBaseTemplatePath()))>
	<cflocation url="index.cfm">
</cfif>
<cfset tickBegin = GetTickCount()>
</cfsilent>