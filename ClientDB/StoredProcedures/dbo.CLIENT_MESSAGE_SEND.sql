USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_MESSAGE_SEND]
	@CLIENT			INT,
	@TYPE			TINYINT,
	@RECEIVE_USER	NVARCHAR(128),
	@NOTE			NVARCHAR(MAX),
	@AUDIT			BIT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DATE DATETIME
	
	SET @DATE = GETDATE()
	
	INSERT INTO dbo.ClientMessage(ID_CLIENT, TP, DATE, NOTE, RECEIVE_USER, HARD_READ)
		VALUES(@CLIENT, @TYPE, @DATE, @NOTE, @RECEIVE_USER, 1)
		
	IF @AUDIT = 1
	BEGIN	
		;WITH user_roles AS
			(
				SELECT u.TYPE, u.name AS US_NAME, u.principal_id AS US_ID
				FROM 
					sys.database_principals u
					INNER JOIN sys.database_role_members ur ON u.principal_id = ur.member_principal_id
					INNER JOIN sys.database_principals r ON r.principal_id = ur.role_principal_id
				WHERE r.TYPE IN ('R') AND r.NAME = 'rl_client_message_audit'
				
				UNION ALL
				
				SELECT r.TYPE, r.name AS US_NAME, r.principal_id AS US_ID
				FROM 
					user_roles u
					INNER JOIN sys.database_role_members ur ON u.US_ID = ur.role_principal_id
					INNER JOIN sys.database_principals r ON r.principal_id = ur.member_principal_id
				
			)
			INSERT INTO dbo.ClientMessage(ID_CLIENT, TP, DATE, NOTE, RECEIVE_USER, HARD_READ, HIDE)
				SELECT @CLIENT, @TYPE, @DATE, @NOTE, US_NAME, 0, 1
				FROM 
					user_roles a
				WHERE a.TYPE IN ('S', 'U')
	END
END
