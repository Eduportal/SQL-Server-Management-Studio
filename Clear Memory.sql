
Checkpoint                                      -- WRITE DIRTY PAGES TO DISK
DBCC FreeProcCache                                    -- CLEAR ENTIRE PROC CACHE
DBCC DropCleanBuffers                                 -- CLEAR ENTIRE DATA CACHE
DBCC FREESESSIONCACHE                                 -- CLEAR ENTIRE SESSION CACHE
DBCC FREESYSTEMCACHE ('ALL') WITH MARK_IN_USE_FOR_REMOVAL;  -- CLEAR ALL SYSTEM CACHE

