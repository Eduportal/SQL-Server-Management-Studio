/*
Configures EVT_BCP message space
*/
exec [Evt].[Configure] @XSpec='
<message-space
	keyword="EVT_BCP"
	name="BCP utility processing"
	retention-period="31"
	raise-error-mask="EVT_FAIL"
	log-mask="EVT_ALL"
	>
	<message keyword="EVT_TRANSFER" text="Bcp.Transfer execution" />
	<message keyword="EVT_TRANSFER_TABLE" text="Bcp.TransferTable execution" />
	<message keyword="EVT_EXPORT" text="Bcp.Export execution" />
	<message keyword="EVT_EXPORT_TABLE" text="Bcp.ExportTable execution" />
	<message keyword="EVT_IMPORT" text="Bcp.Import execution" />
	<message keyword="EVT_HASH"  text="Bcp.ComputeHash execution" />
	<message keyword="EVT_DIRECTORY" text="Bcp.DirectoryInfo() execution" />
	<message keyword="EVT_QUERY" text="Bcp.Query execution" />
	<message keyword="EVT_RPC"  text="Bcp.Rpc execution" />
	<message keyword="EVT_CLEANUP"  text="Bcp.Cleanup execution" />
	<message keyword="EVT_WRITEFILE"  text="Bcp.WriteFile execution" />
	<message keyword="EVT_READFILE"  text="Bcp.ReadFile execution" />
	<message keyword="EVT_COPYFILE"  text="Bcp.CopyFile execution" />
	<message keyword="EVT_DELETEFILE"  text="Bcp.DeleteFile execution" />
	<message keyword="EVT_TRIMPROC" text="Bcp.TrimProcessList execution" />
	<message keyword="EVT_GETPROC" text="Bcp.GetProcessList execution" />
	<message keyword="EVT_INSRTPROC" text="Bcp.InsertProcessList execution" />
</message-space>' ;