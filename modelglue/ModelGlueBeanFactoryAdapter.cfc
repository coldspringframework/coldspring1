<cfcomponent
	extends="ModelGlue.Bean.BeanFactory">
		
	<cffunction name="init" returntype="coldspring.modelglue.ModelGlueBeanFactoryAdapter" access="public" output="false">
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="setBeanFactory" access="public" returnType="any" output="false" 
				hint="Dependency: the real coldspring bean factory to use">
   		<cfargument name="beanFactory" type="coldspring.beans.BeanFactory" required="true" />
	
   		<cfset variables.myBeanFactory = arguments.beanFactory />		

	</cffunction>


	<cffunction name="CreateBean" access="public" returnType="any" output="false" hint="I create a bean from an XML file.">
   		<cfargument name="beanFile" type="string" required="true" hint="I am the filename representing the bean to instantiate." />

		<!--- if the bean name ends with .xml (which it should), we'll strip off the extension
			  typically you would register beans in coldspring just by their name  --->

   		<cfset var beanName = arguments.beanFile />
		<cfif right(arguments.beanFile,4) eq ".xml">
			<cfset beanName = mid(arguments.beanFile,1,len(arguments.beanFile)-4) />
		</cfif>


		<!--- now we try to get the bean from coldspring by this adjusted name.
			  If coldspring doesn't recognize, we try with the original "filename"
			   --->
		<cftry>
			<cfreturn variables.myBeanFactory.getBean(beanName)>/>
			
			<cfcatch type="coldspring.NoSuchBeanDefinitionException">
				<cfreturn variables.myBeanFactory.getBean(arguments.beanFile)>/>
			</cfcatch>
			
		</cftry>		
	</cffunction>

</cfcomponent>