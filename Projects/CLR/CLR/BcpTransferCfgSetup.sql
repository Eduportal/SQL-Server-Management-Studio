exec Cfg.Configure @XSpec=N'<property-space code="BcpTransfer">
	<property
		code="UseEvtLogging"
		name="Use EVT logging when running the BcpTransfer sproc"
		data-type="bit"
		description="A bit to determine whether to use EVT logging, or else send messages to the caller"
		default-value="True"
		/>
	<property
		code="DoesExtendedLogging"
		name="Do extended (diagnostic-level) logging?"
		data-type="bit"
		description="When set to true, the BcpTransfer sproc does extended-level logging, useful for pinpointing potential trouble spots in the sproc."
		default-value="True"
		/>
	<property
		code="IsInTestMode"
		name="Use test mode?"
		data-type="bit"
		description="When enabled, goes into test mode, which does everything (including opening connections) but does not transfer any data."
		default-value="False"
		/>
	<property
		code="DoesRowCounts"
		name="Support row counts for transfer and export operations"
		data-type="bit"
		description="When enabled, supports row counts when doing Bcp.Transfer and Bcp.Export, for logging purposes."
		default-value="False"
		/>
	<property
		code="AllowOverwrites"
		name="Allow file overwrites when exporting data."
		data-type="bit"
		description="1=Overwrite a file when exporting if it exists. 0=Do not allow overwrites and error."
		default-value="False"
		/>
	<property
		code="FileNameFilter"
		name="Default file name filter when looking through at files"
		data-type="string"
		description="The Windows file filter (e.g. *.* ) when using the CLR directory info functions."
		default-value="*.*"
		/>
	<property
		code="ColumnDelimiter"
		name="Default file export column delimiter"
		data-type="string"
		description="The default column delimiter (such as a comma or tab) when exporting tabular data to a file."
		default-value="	"
		/>
	<property
		code="RowDelimiter"
		name="Default file export row delimiter"
		data-type="string"
		description="The default row delimiter (such as a carriage return) when exporting tabular data to a file."
		default-value="
		"
		/>
	<property
		code="DoTableLock"
		name="Default setting for whether to do a full table lock during the BULK INSERT"
		data-type="bit"
		description="1=Do a full table lock. 0=Allow SQL to pick locking granularity."
		default-value="True"
		/>
	<property
		code="BatchSize"
		name="Default BULK INSERT batch size when transferring data"
		data-type="int"
		description="The number of rows per batch when transferring data. 0=entire transfer in one batch"
		default-value="5000"
		/>
	<property
		code="ConnectionTimeout"
		name="Default SQL connection timeout when select and transferring data"
		data-type="int"
		description="The connection time (in seconds) before a SQL connection times out at the source or destination."
		default-value="1200"
		/>
	<property
		code="UseOneTransaction"
		name="Default setting for whether to use a single transaction when loading data."
		data-type="bit"
		description="1=Use one transaction for the entire transfer. 0=Use 0 or multiple transactions."
		default-value="True"
		/>
	<property
		code="UseMultipleTransactions"
		name="Default setting for whether to use multiple transactions when loading data."
		data-type="bit"
		description="1=Use one transaction per batch when transferring data. 0=Use 1 or multiple transactions."
		default-value="False"
		/>
	<property
		code="CheckConstraints"
		name="Default value for whether to "
		data-type="bit"
		description="0=Do not check constraints (including FK) when bulk loading data. 1=Do all constraint checks."
		default-value="1"
		/>
	<property
		code="FireTriggers"
		name="Default setting for whether to fire triggers when transferring data"
		data-type="bit"
		description="0=Do not fire triggers when bulk loading data. 1=Fire triggers when bulk loading data."
		default-value="1"
		/>
	<property
		code="KeepIdentityValues"
		name="Default setting for whether to keep identity values when inserting into an IDENTITY-keyed table"
		data-type="bit"
		description="0=Do not keep source identity values. 1=Keep source identity values"
		default-value="1"
		/>
	<property
		code="KeepNullValues"
		name="Default setting for whether to keep null values when transferring data."
		data-type="bit"
		description="1=Keep null values. 0=Allow defaults to replace NULL values"
		default-value="1"
		/>
	<property
		code="UseSafeExport"
		name="Default setting for whether to turn varchar/nvarchar/text values into hexadecimal values when exporting."
		data-type="bit"
		description="1=Turn varchar/nvarchar/text columns into hex code. 0=Print varchar/nvarchar/text values as raw text"
		default-value="0"
		/>
	<property
		code="UseSafeImport"
		name="Default setting for whether to turn hexadecimal values into varchar/nvarchar/text values when importing."
		data-type="bit"
		description="Default setting for whether to turn hexadecimal values into varchar/nvarchar/text values when importing."
		default-value="0"
		/>
	<property
		code="SafeExportMaxErrors"
		name="Maximum number of errors allowed when doing a safe (bcp.exe) export"
		data-type="int"
		description=""
		default-value="1"
		/>
	<property
		code="SafeExportFormatEnum"
		name="Enumerator for which format to use when safe exporting (bcp.exe) files."
		data-type="int"
		description="1=use native mode. 2=use native format with Unicode characters. 3=use character format. 4=use Unicode format"
		default-value="2"
		/>
</property-space>'