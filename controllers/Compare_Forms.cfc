<cfcomponent extends="Controller">

	<cffunction name="compare_forms" returnType="any" access="public" output="true">
		<cfif isDefined("form.file_paths") AND len(trim(form.file_paths))>
			<cffile
				action="uploadAll"
				destination="#getDirectoryFromPath(expandPath(cgi.script_name))#files\temporary_uploads\"
				accept="text/plain"
				nameconflict="overwrite"
				result="request.aryFiles"
			/>

			<cfset request.aryFileQueries = arrayNew(1)/>

			<cfloop array="#request.aryFiles#" index="request.i">
				<cfif fileExists(request.i.serverDirectory & "\" & request.i.serverFile)>
					<cffile action="read" file="#request.i.serverDirectory#\#request.i.serverFile#" variable="request.strFileContent"/>

					<cfset request.strFormName = getTagContent(request.strFileContent, "formName", ":")/>

					<cfset arrayAppend(
						request.aryFileQueries
						, parseFileContent(
							request.strFileContent
							, request.i.clientFile
							, request.strFormName
						)
					)/>
				</cfif>

			</cfloop>
			<cfset request.lstQueryColumns = arrayToList(request.aryFileQueries[1].getColumnList())/>

			<cfset request.qryData = queryMerge(request.aryFileQueries)/>

			<cfset local.aryCheckData = [
				{strFieldName = "field_label_stripped"}
				, {strFieldName = "field_label", strBefore = "MAX(", strAfter = ")", strAlias = "field_label", bolExcludeFromGroupBy = true}
			]/>

			<cfif structKeyExists(form, "include_data_type")>
				<cfset arrayAppend(
					local.aryCheckData
					, {strFieldName = "data_type", strBefore = "LOWER(", strAfter = ")", strAlias = "data_type"}
				)/>
			</cfif>

			<cfset request.qryFieldLabels = getDistinctFieldsFromQuery(request.qryData, local.aryCheckData)/>

			<cfset request.qryFormNames = getDistinctFieldsFromQuery(request.qryData, [{strFieldName = "form_name"}])/>
		</cfif>
	</cffunction>

</cfcomponent>