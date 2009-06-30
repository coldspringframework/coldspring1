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

 $Id: AnnotationPointcut.cfc,v 1.4 2009/06/30 01:42:46 mandelm Exp $
 $Log: AnnotationPointcut.cfc,v $
 Revision 1.4  2009/06/30 01:42:46  mandelm
 remove _trace

 Revision 1.3  2009/03/06 00:34:25  mandelm
 Bug in the annotation pointcut - it was returning a match on ALL methods in a CFC, if only 1 method in that cfc had the annotation.

 Revision 1.2  2009/02/25 06:16:18  mandelm
 All for '*' wildcard in the Annotation pointcut.

 Revision 1.1  2009/02/24 23:51:44  anoncvs
 Annotation Pointcuts for AOP

--->

<cfcomponent name="AnntoationPointcut"
			displayname="AnntoationPointcut"
			extends="coldspring.aop.Pointcut"
			hint="Pointcut to match annotations"
			output="false">

	<cfset variables.annotations = 0 />

	<cffunction name="init" access="public" returntype="coldspring.aop.support.AnnotationPointcut" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="matches" access="public" returntype="boolean" output="true">
		<cfargument name="methodName" type="string" required="true" />
		<cfargument name="metadata" hint="the cfc meta data we're trying to match" type="struct" required="Yes">
		<cfscript>
			var len = 0;
			var func = 0;
			var counter = 0;

			//traverse the meta, and see if any of our annotations match
			while(StructKeyExists(arguments.metadata, "extends"))
			{
				if(StructKeyExists(arguments.metadata, "functions"))
				{
					len = ArrayLen(arguments.metadata.functions);
					for(counter = 1; counter lte len; counter = counter + 1)
					{
						func = arguments.metadata.functions[counter];

						if(func.name eq arguments.methodName AND isMatch(func))
						{
							return true;
						}
					}
				}

				arguments.metadata = arguments.metadata.extends;
			}

			return false;
		</cfscript>
	</cffunction>

	<cffunction name="getAnnotations" access="private" returntype="struct" output="false">
		<cfreturn variables.annotations />
	</cffunction>

	<cffunction name="setAnnotations" access="public" returntype="void" output="false">
		<cfargument name="annotations" type="struct" required="true">
		<cfset variables.annotations = arguments.annotations />
	</cffunction>

	<cffunction name="isMatch" hint="returns if the current methods meta data matches any of the given annotations provided" access="private" returntype="boolean" output="false">
		<cfargument name="meta" hint="the function's meta data" type="struct" required="Yes">getAnnotations

		<cfset var annotation = 0 />
		<cfset var value = 0 />

		<cfloop collection="#getAnnotations()#" item="annotation">
			<cfscript>
				//check if it exists, and the values match
				if(StructKeyExists(arguments.meta, annotation) AND
					(
					StructFind(getAnnotations(), annotation) eq "*"
					OR
					arguments.meta[annotation] eq StructFind(getAnnotations(), annotation)
					))
				{
					return true;
				}
			</cfscript>
		</cfloop>

		<cfreturn false />
	</cffunction>

</cfcomponent>