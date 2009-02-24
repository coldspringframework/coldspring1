<!---

  Copyright (c) 2005, Chris Scott, David Ross, Kurt Wiersma, Sean Corfield
  All rights reserved.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

 $Id: AnnotationPointCutAdvisor.cfc,v 1.1 2009/02/24 23:51:44 anoncvs Exp $
 $Log: AnnotationPointCutAdvisor.cfc,v $
 Revision 1.1  2009/02/24 23:51:44  anoncvs
 Annotation Pointcuts for AOP


--->

<cfcomponent name="AnnotationPointcutAdvisor"
			extends="coldspring.aop.support.DefaultPointcutAdvisor"
			hint="Pointcut advisor to match annotations on methods"
			output="false">

	<cffunction name="init" access="public" returntype="coldspring.aop.support.DefaultPointcutAdvisor" output="false">
		<cfset setPointcut(CreateObject('component','coldspring.aop.support.AnnotationPointcut').init()) />
		<cfreturn this />
	</cffunction>

	<cffunction name="setAnnotations" access="public" hint="Key value pairs to look for as annotations" returntype="void" output="false">
		<cfargument name="annotation" type="struct" required="true" />
		<cfset variables.pointcut.setAnnotations(arguments.annotation) />
	</cffunction>

	<cffunction name="matches" access="public" returntype="boolean" output="true">
		<cfargument name="methodName" type="string" required="true" />
		<cfargument name="metadata" hint="the cfc meta data we're trying to match" type="struct" required="Yes">

		<cfreturn getPointcut().matches(argumentCollection=arguments) />
	</cffunction>

</cfcomponent>