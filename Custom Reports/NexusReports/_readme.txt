To edit reports, edit them in the NexusReports project, NOT the sqlnexus project.  

To add a new report, add it to the NexusReports project as an .RDL file. Child reports that need to 
be accessible via drillthrough should have an _C suffix (e.g. MyChildReport_C.RDL). Top-level reports 
that should be accessible from the left-hand pane must have an .RDL extension. 
 1. Add the new .RDL file to NexusReports. Do any report design work on this copy. 
 2. Check the NexusReports copy of the report (.RDL) into the source depot. 
 3. Build the sqlnexus project once. A pre-build step will copy the report from the NexusReports 
    project to the sqlnexus\Reports folder. 
 4. Add the .RDL/.RDLC file in the sqlnexus\Reports folder to the Reports folder in the sqlnexus 
    project. This step just involves adding the report to the sqlnexus project in Visual Studio; 
    you should not check the files in sqlnexus\Reports into the depot since they will be re-copied 
    from the NexusReports folder each time sqlnexus builds. 
 5. In VS, make the following modifications to the properties of the file in sqlnexus\Reports: 
       Build Action              --> "Content"
       Copy to Output Directory  --> "Copy Always"

All of this is necessary because child reports must be .RDLC files for drillthrough to work at runtime, 
but the same report must have a different file extension (.RDL) for drillthrough to work at design time. 

The sqlnexus project has a pre-build step that does the following: 
 1. Copy all .RDL files from the NexusReports directory to the sqlnexus\Reports directory. 
 2. Rename any reports with an _C suffix to .RDLC (e.g. MyChildReport_C.rdl --> MyChildReport_C.rdlC). 
