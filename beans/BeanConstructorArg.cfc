<!---
	 $Id: BeanConstructorArg.cfc,v 1.1 2005/09/22 00:34:17 rossd Exp $
	 $log$
---> 

<cfcomponent>

	<cfset variables.instanceData = StructNew() />

	<cffunction name="init" returntype="coldspring.beans.BeanConstructorArg" access="public" output="false">
		<cfargument name="constructorArgDefinition" type="any" required="true" />
		<cfargument name="parentBeanDefinition" type="coldspring.beans.BeanDefinition" />
		
		<cfset setParentBeanDefinition(arguments.parentBeanDefinition) />
		<cfset parseConstructorArgDefinition(arguments.constructorArgDefinition) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="parseConstructorArgDefinition" access="private" returntype="void" output="false">
		<cfargument name="constructorArgDefinition" type="any" required="true" />
		<cfset var child = 0 />
		<cfset var beanUID = 0 />
		
		<cfif not (StructKeyExists(constructorArgDefinition.XmlAttributes,'name') and StructKeyExists(constructorArgDefinition,'XmlChildren'))
			  	and ArrayLen(arguments.constructorArgDefinition.XmlChildren)>
			<cfthrow type="coldspring.MalformedBeanException" message="contructor-argument definition must contain a 'name' and a child element!">
		</cfif>
		
		<cfset setName(constructorArgDefinition.XmlAttributes.name) />
		
		<cfset child = arguments.constructorArgDefinition.XmlChildren[1] />
		<cfset setType(child.XmlName) />
			
		<!--- this needs to implements maps and lists, but I'm only going to do bean refs and values for now --->
		<cfswitch expression="#child.xmlName#">
			
			<cfcase value="ref">
				<cfset setValue(child.xmlAttributes.bean) />
				<cfset addParentDefinitionDependency(child.xmlAttributes.bean) />
			</cfcase>
			
			<cfcase value="bean">
				<cfif not (StructKeyExists(child.XmlAttributes,'class'))>
					<cfthrow type="coldspring.MalformedInnerBeanException" message="Xml inner bean definitions must contain a 'class' attribute!">
				</cfif>
				<!--- create uid for new Bean, store as value for lookup --->
				<cfset beanUID = CreateUUID() />
				<cfset setValue(beanUID) />
				<cfset createInnerBeanDefinition(beanUID, child.XmlAttributes.class, child.XmlChildren) />
				<cfset addParentDefinitionDependency(beanUID) />
			</cfcase>
			
			<cfcase value="list">
				<cfset setValue(parseEntries(child.xmlChildren,'list')) />
			</cfcase>
			
			<cfcase value="value">
				<cfset setValue(child.xmlText) />
			</cfcase>
			
		</cfswitch>
			
	</cffunction>
	
	<cffunction name="parseEntries" access="private" returntype="any" output="false">
		<cfargument name="mapEntries" type="array" required="true" />
		<cfargument name="returnType" type="string" required="true" />
		<cfset var rtn = 0 />
		<cfset var ix = 0/>
		<cfset var entry = 0/>
		<cfset var entryChild = 0/>
		
		<!--- only lists are implemented so far --->
		<cfif returnType IS 'list'>
			<cfset rtn = ArrayNew(1) />
			<cfloop from="1" to="#ArrayLen(mapEntries)#" index="ix">
				<cfset entry = arguments.mapEntries[ix]/>
				<!--- nothing but value types in the list are supported --->
				<cfif entry.xmlName IS 'value'>
					<cfset ArrayAppend(rtn, entry.xmlText) />
				</cfif>
			</cfloop>
			<cfreturn rtn />
		</cfif>
		
	</cffunction>
	
	<cffunction name="addParentDefinitionDependency" access="private" returntype="void" output="false">
		<cfargument name="refName" type="string" required="true"/>
		<cfset getParentBeanDefinition().addDependency(arguments.refName) />
	</cffunction>
	
	<cffunction name="getParentBeanDefinition" access="public" returntype="coldspring.beans.BeanDefinition" output="false">
		<cfreturn variables.instanceData.parentBeanDefinition />  
	</cffunction>
	
	<cffunction name="setParentBeanDefinition" access="public" returntype="void" output="false">
		<cfargument name="parentBeanDefinition" type="coldspring.beans.BeanDefinition" />
		<cfset variables.instanceData.parentBeanDefinition = arguments.parentBeanDefinition />
	</cffunction>
	
	<cffunction name="createInnerBeanDefinition" access="public" returntype="void" output="false">
		<cfargument name="beanID" type="string" required="true" />
		<cfargument name="beanClass" type="string" required="true" />
		<cfargument name="children" type="any" required="true" />
		<!--- call parent's bean factory to create new bean definition --->
		<cfset getParentBeanDefinition().getBeanFactory().createBeanDefinition(arguments.beanID, arguments.beanClass, arguments.children, false, true) />
	</cffunction>
	
	<cffunction name="getName" access="public" output="false" returntype="string" hint="I retrieve the Name from this instance's data">
		<cfreturn variables.instanceData.Name/>
	</cffunction>

	<cffunction name="setName" access="public" output="false" returntype="void"  hint="I set the Name in this instance's data">
		<cfargument name="Name" type="string" required="true"/>
		<cfset variables.instanceData.Name = arguments.Name/>
	</cffunction>

	<cffunction name="getType" access="public" output="false" returntype="string" hint="I retrieve the Type from this instance's data">
		<cfreturn variables.instanceData.Type/>
	</cffunction>

	<cffunction name="setType" access="public" output="false" returntype="void"  hint="I set the Type in this instance's data">
		<cfargument name="Type" type="string" required="true"/>
		<cfset variables.instanceData.Type = arguments.Type/>
	</cffunction>
	
	<cffunction name="getValue" access="public" output="false" returntype="any" hint="I retrieve the Value from this instance's data">
		<cfreturn variables.instanceData.Value/>
	</cffunction>

	<cffunction name="setValue" access="public" output="false" returntype="void"  hint="I set the Value in this instance's data">
		<cfargument name="Value" type="any" required="true"/>
		<cfset variables.instanceData.Value = arguments.Value/>
	</cffunction>
	
</cfcomponent>