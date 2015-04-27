-- STAGE 1: SETUP TARGET DATABASE
 

      USE master;
 

      /* Create Target Database */
 

            IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Target') DROP DATABASE Target;
            CREATE DATABASE Target
            GO
            -- Activate the Broker in this database (can only be done with ALTER DATABASE)
            ALTER DATABASE Target SET ENABLE_BROKER
 

      USE Target;             
 

            -- Create the database master key
            CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<Specify a password here>'
            GO
 

      /* Set up Target User, and place certificate (without private key) in a file */
 

            -- Create Target User without login
            IF EXISTS (SELECT * FROM sys.sysusers WHERE name = 'TargetUser') DROP USER TargetUser;
            CREATE USER TargetUser WITHOUT LOGIN
 

            -- Create a Cert for the Initiator user
            IF EXISTS (SELECT * FROM sys.certificates WHERE name = 'TargetCert') DROP CERTIFICATE TargetCert;
            CREATE CERTIFICATE TargetCert 
                  AUTHORIZATION TargetUser
                        WITH SUBJECT = 'Target Certificate', EXPIRY_DATE = '10/31/2009';
 

            -- Backup the cert up so the Target database can import the cert (public key)
            BACKUP CERTIFICATE TargetCert TO FILE = 'c:\TargetCert.cer';
            GO
 

      /* Set up SSB */
 

            -- First, we need to create a message type. This message type is very simple and allows any type of content
            -- (Drop contract because it binds to message)
            IF EXISTS (SELECT * FROM sys.service_contracts WHERE name = 'SubmissionContract') DROP CONTRACT SubmissionContract;
            IF EXISTS (SELECT * FROM sys.service_message_types WHERE name = 'Message') DROP MESSAGE TYPE Message;
            CREATE MESSAGE TYPE Message VALIDATION = NONE
            
            -- Now create a contract that specifies what type types of messages
            CREATE CONTRACT SubmissionContract (Message SENT BY INITIATOR)
 

            -- Set up Target receive queue to hold messages
            -- (Need to drop service before queue, due to binding)
            IF EXISTS (SELECT * FROM sys.services WHERE name = 'TargetService') DROP SERVICE TargetService;
            IF EXISTS (SELECT * FROM sys.service_queues WHERE name = 'TargetQueue') DROP QUEUE TargetQueue;
            CREATE QUEUE TargetQueue
 

            -- Create the required service and bind to be above created queue
            CREATE SERVICE TargetService
            AUTHORIZATION TargetUser
            ON QUEUE TargetQueue (SubmissionContract)
 

            -- Create a Local Route for the destination TargetService
            IF EXISTS (SELECT * FROM sys.routes WHERE name = 'InitiatorRoute') DROP ROUTE InitiatorRoute;
            CREATE ROUTE InitiatorRoute WITH SERVICE_NAME = 'InitiatorService',     ADDRESS = 'LOCAL'
            GO
 

-- STAGE 2: SETUP INITIATOR DATABASE
 

      USE master;
 

      /* Create Initiator Database */
            
            IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Initiator') DROP DATABASE Initiator;
            CREATE DATABASE Initiator;
            GO
            -- Activate the Broker in this database
            ALTER DATABASE Initiator SET ENABLE_BROKER;
 

      USE Initiator;
 

            -- Create the database master key
            CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<Specify a password here>';
            GO
 

      /* Set up Initiator User */
 

            -- Create Initiator User without Login
            IF EXISTS (SELECT * FROM sys.sysusers WHERE name = 'InitiatorUser01') DROP USER InitiatorUser01;
            CREATE USER InitiatorUser01 WITHOUT LOGIN;
 

            -- Create a Cert with InitiatorUser AUTHORIZATION
            -- This links the Cert to the User so SSB uses the CERT for Dialog security
            IF EXISTS (SELECT * FROM sys.certificates WHERE name = 'InitiatorCert01') DROP CERTIFICATE InitiatorCert01;
            CREATE CERTIFICATE InitiatorCert01 
                  AUTHORIZATION InitiatorUser01
                        WITH SUBJECT = 'Initiator Certificate 01', EXPIRY_DATE = '10/31/2009';
 

            -- Backup the cert up so the Target can import the cert (public key)
            BACKUP CERTIFICATE InitiatorCert01 TO FILE = 'c:\InitiatorCert01.cer';
            GO
 

      /* Set up SSB */
 

            -- First, we need to create a message type. Note that our message type is
            -- very simple and allows any type of content
            -- (Need to drop contract before message, due to binding)
            IF EXISTS (SELECT * FROM sys.service_contracts WHERE name = 'SubmissionContract') DROP CONTRACT SubmissionContract;
            IF EXISTS (SELECT * FROM sys.service_message_types WHERE name = 'Message') DROP MESSAGE TYPE Message;
            CREATE MESSAGE TYPE Message VALIDATION = NONE;
 

            -- Once the message type has been created, we need to create a contract
            -- that specifies who can send what types of messages
            CREATE CONTRACT SubmissionContract (Message SENT BY INITIATOR);
 

            -- Set up Initiator send queue to hold messages
            -- (Need to drop service before queue, due to binding)
            IF EXISTS (SELECT * FROM sys.services WHERE name = 'InitiatorService') DROP SERVICE InitiatorService;
            IF EXISTS (SELECT * FROM sys.service_queues WHERE name = 'InitiatorQueue') DROP QUEUE InitiatorQueue;
            CREATE QUEUE InitiatorQueue;
            
            -- Create the Initiator service and bind to be above created Initiator queue
            CREATE SERVICE InitiatorService
                  AUTHORIZATION InitiatorUser01 ON QUEUE InitiatorQueue;
 

            -- Create a Local Route for the destination TargetService
            IF EXISTS (SELECT * FROM sys.routes WHERE name = 'TargetRoute') DROP ROUTE TargetRoute;
            CREATE ROUTE TargetRoute WITH SERVICE_NAME = 'TargetService', ADDRESS = 'LOCAL'
            GO
 

      /* Set up the Target user using the Target EXPORTED CERT  */
 

            -- Create Target User without login
            IF EXISTS (SELECT * FROM sys.sysusers WHERE name = 'TargetUser') DROP USER TargetUser;
            CREATE USER TargetUser WITHOUT LOGIN;
 

            -- Create a Cert from the external cert file
            CREATE CERTIFICATE TargetCert 
                  AUTHORIZATION TargetUser
                        FROM FILE = 'c:\TargetCert.cer'
            GO
 

            -- Create a remote service binding (only needs to be done on the initator)
            CREATE REMOTE SERVICE BINDING TargetBinding
                  TO SERVICE 'TargetService'
                  WITH USER = TargetUser
            GO
 

-- STAGE 3: 
 

      use Target;
 

      /* Set up the Target user using the Target EXPORTED CERT  */
 

            -- Create Initiator User without Login
            IF EXISTS (SELECT * FROM sys.sysusers WHERE name = 'InitiatorUser01') DROP USER InitiatorUser01;
            CREATE USER InitiatorUser01 WITHOUT LOGIN
 

            -- Create a Cert with InitiatorUser AUTHORIZATION
            -- This links the Cert to the User so SSB uses the CERT for Dialog security
            IF EXISTS (SELECT * FROM sys.certificates WHERE name = 'InitiatorCert01') DROP CERTIFICATE InitiatorCert01;
            
            -- Create a Cert from the external cert file
            CREATE CERTIFICATE InitiatorCert01 
                  AUTHORIZATION InitiatorUser01
                        FROM FILE = 'c:\InitiatorCert01.cer'
            GO
 

            GRANT SEND ON SERVICE::TargetService TO InitiatorUser01
            GO
 

-- STAGE 4: Create a proc send SSB Message from Initiator to Target
 

      USE Initiator;
      
      /* Send Proc To Send SSB Message from Initiator to Target */
      
            IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SendMessageProc') DROP PROCEDURE SendMessageProc;    
            GO
 

            CREATE PROCEDURE SendMessageProc AS
                  BEGIN
 

                        DECLARE @conversationHandle UNIQUEIDENTIFIER
                        DECLARE @message NVARCHAR(100)
 

                        BEGIN TRANSACTION;
                              BEGIN DIALOG @conversationHandle
                                          FROM SERVICE InitiatorService
                                          TO SERVICE 'TargetService'
                                          ON CONTRACT SubmissionContract
                              
                              -- Send a message on the conversation
                              SET @message = N'Your first cross database Secure SQL Service Broker message';
                              SEND ON CONVERSATION @conversationHandle
                                          MESSAGE TYPE Message (@message)
 

                        COMMIT TRANSACTION
 

                  END
            GO
 

      /* Send your first SSB message */
 

      USE Initiator;
 

            EXEC SendMessageProc;
            GO
 

-- STAGE 5: Make sure your message got there
 

      USE Target;
      GO
 

            SELECT convert( nvarchar(max), message_body ) from TargetQueue
            GO
