<cfsilent>
	<cfset path = ExpandPath('.') />
	<cfset configFile = path & "/parentBeans.xml" />
	<cfset beanFactory = CreateObject('component', 'coldspring.beans.DefaultXmlBeanFactory').init() />
	<cfset beanFactory.loadBeans(configFile) />
</cfsilent>

<cfset bookmarkService = beanFactory.getBean("bookmarkService")>

<cfdump var="#bookmarkService#">