exec sp_Help_Doc 'dbaudf_GetFileProperty','UPDATE','Description',
' NOTE: Test for File InUse does not error if the file does not exist, Only if the file name or path is invalid and/or can not be created.

@GetAS=file    @Property =      InUse  (RESULTS: 0=not In Use,1=In Use,2=bad file or path)
                                Format (RESULTS: The Specific File Format)
                                Attributes
                                CreationTime
                                CreationTimeUtc
                                DirectoryName
                                Exists (Results: "True" or "The File xxxx Does Not Exist")
                                Extension (Results: will include the dot)
                                FullName
                                IsReadOnly
                                LastAccessTime
                                LastAccessTimeUtc
                                LastWriteTime
                                LastWriteTimeUtc
                                Length
                                Name

@GetAS=folder   @Property =     Attributes
                                CreationTime
                                CreationTimeUtc
                                Exists (Results: "True" or "The Folder xxxx Does Not Exist")
                                Extension (Results: will include the dot)
                                FullName
                                LastAccessTime
                                LastAccessTimeUtc
                                LastWriteTime
                                LastWriteTimeUtc
                                Name
                                Parent
                                Root

@GetAS=drive     @Property =    AvailableFreeSpace
                                DriveFormat
                                DriveType
                                IsReady
                                Name
                                RootDirectory
                                TotalFreeSpace
                                TotalSize
                                VolumeLabel'

