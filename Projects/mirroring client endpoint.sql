/****** Object:  Endpoint [Mirroring]    Script Date: 01/17/2013 12:42:36 ******/
IF  EXISTS (SELECT * FROM sys.endpoints e WHERE e.name = N'Mirroring') 
DROP ENDPOINT [Mirroring]
GO

/****** Object:  Endpoint [Mirroring]    Script Date: 01/17/2013 12:42:36 ******/
CREATE ENDPOINT [Mirroring] 
	AUTHORIZATION [sa]
	STATE=STARTED
	AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE
, ENCRYPTION = REQUIRED ALGORITHM RC4)
GO


