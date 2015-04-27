--select		output_file_name
--			,REPLACE(output_file_name,PARSENAME(output_file_name,2),PARSENAME(output_file_name,2)+'_$(ESCAPE_NONE(STRTDT))')
			

--From sysjobsteps



UPDATE		sysjobsteps
	SET		output_file_name = REPLACE(output_file_name,PARSENAME(output_file_name,2),PARSENAME(output_file_name,2)+'_$(ESCAPE_NONE(STRTDT))')
WHERE		PARSENAME(output_file_name,2) NOT like '%_$(ESCAPE_NONE(STRTDT))'

