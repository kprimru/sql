USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONNECT]
	@CLIENT	NVARCHAR(MAX),
	@DATE	SMALLDATETIME,
	@STATUS	INT,
	@SYSTEM	BIT,
	@SLIST	NVARCHAR(MAX),
	@NOTE	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ClientDisconnect(CD_ID_CLIENT, CD_TYPE, CD_DATE, CD_ID_STATUS, CD_NOTE)
		SELECT ID, 2, @DATE, @STATUS, @NOTE
		FROM dbo.TableIDFromXML(@CLIENT)
		
	UPDATE dbo.ClientTable
	SET StatusID = @STATUS
	WHERE ClientID IN
		(
			SELECT ID
			FROM dbo.TableIDFromXML(@CLIENT)
		) AND STATUS = 1
	
	DECLARE @DS_ON	UNIQUEIDENTIFIER
	DECLARE @DS_OFF	UNIQUEIDENTIFIER
		
		
	IF @SYSTEM = 1 OR @SLIST IS NOT NULL
	BEGIN		
		SELECT @DS_ON = DS_ID
		FROM dbo.DistrStatus
		WHERE DS_REG = 0
		
		SELECT @DS_OFF = DS_ID
		FROM dbo.DistrStatus
		WHERE DS_REG = 1
		
		IF @SYSTEM = 1
		BEGIN
			INSERT INTO dbo.ClientDistr(ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, STATUS, BDATE, EDATE, UPD_USER)
				SELECT ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, 2, BDATE, GETDATE(), UPD_USER
				FROM dbo.ClientDistr
				WHERE ID_CLIENT IN 
					(
						SELECT ID
						FROM dbo.TableIDFromXML(@CLIENT)
					) AND ID_STATUS <> @DS_ON
					AND STATUS = 1
		
			UPDATE dbo.ClientDistr
			SET ID_STATUS	= @DS_ON,
				ON_DATE		= @DATE,
				BDATE		= GETDATE(),
				UPD_USER	= ORIGINAL_LOGIN()		
			WHERE ID_CLIENT IN 
				(
					SELECT ID
					FROM dbo.TableIDFromXML(@CLIENT)
				) AND ID_STATUS <> @DS_ON
				AND STATUS = 1			
		END
		ELSE
		BEGIN
			INSERT INTO dbo.ClientDistr(ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, STATUS, BDATE, EDATE, UPD_USER)
				SELECT ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, 2, BDATE, GETDATE(), UPD_USER
				FROM dbo.ClientDistr
				WHERE ID IN 
					(
						SELECT ID
						FROM dbo.TableGUIDFromXML(@SLIST)
					) AND ID_STATUS <> @DS_ON
					AND STATUS = 1
		
			UPDATE dbo.ClientDistr
			SET ID_STATUS	= @DS_ON,
				ON_DATE		= @DATE,
				BDATE		= GETDATE(),
				UPD_USER	= ORIGINAL_LOGIN()		
			WHERE ID IN 
				(
					SELECT ID
					FROM dbo.TableGUIDFromXML(@SLIST)
				) AND ID_STATUS <> @DS_ON
				AND STATUS = 1			
		END
	END
END