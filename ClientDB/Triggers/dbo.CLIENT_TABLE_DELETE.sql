USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[CLIENT_TABLE_DELETE]
   ON  [dbo].[ClientTable]
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD XML

	DECLARE @ID INT

	DECLARE @FULL VARCHAR(250)
	DECLARE @ADDRESS VARCHAR(250)
	DECLARE @INN VARCHAR(50)

	DECLARE @DIR VARCHAR(150)
	DECLARE @DIR_PHONE VARCHAR(50)

	DECLARE @BUH VARCHAR(150)
	DECLARE @BUH_PHONE VARCHAR(50)

	DECLARE @RES VARCHAR(150)
	DECLARE @RES_PHONE VARCHAR(50)
	DECLARE @RES_POS VARCHAR(150)

	DECLARE @SERVICE VARCHAR(150)

	DECLARE @STATUS VARCHAR(50)

	DECLARE CL CURSOR LOCAL FOR
		SELECT 
			ClientID, 
			REPLACE(REPLACE(REPLACE(REPLACE(ClientFullName, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ClientAdress, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ClientINN, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ClientDir, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ClientDirPhone, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ClientBuh, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ClientBuhPhone, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ClientRes, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ClientResPhone, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ClientResPosition, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ServiceStatusName, '"', '_'), '<', '_'), '>', '_'), '&', '_'),
			REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(
			(
				SELECT ServiceName
				FROM dbo.ServiceTable
				WHERE ServiceID = ClientServiceID
			), ''), '"', '_'), '<', '_'), '>', '_'), '&', '_')
		FROM 
			DELETED INNER JOIN
			dbo.ServiceStatusTable ON DELETED.StatusID = ServiceStatusTable.ServiceStatusID

	OPEN CL

	FETCH NEXT FROM CL INTO
		@ID, @FULL, @ADDRESS, @INN, @DIR, @DIR_PHONE, @BUH, @BUH_PHONE, @RES, @RES_PHONE, @RES_POS, @STATUS, @SERVICE
		
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SET @OLD =	'<VALUES NAME="' + @FULL + '" ADDRESS="' + @ADDRESS + '" INN="' + @INN + '" DIR="' + @DIR + '" ' + 
					'DIR_PHONE="' + @DIR_PHONE + '" BUH="' + @BUH + '" BUH_PHONE="' + @BUH_PHONE + '" ' + 
                    'RES="' + @RES + '" RES_PHONE="' + @RES_PHONE + '" RES_POS="' + @RES_POS + '" ' + 
					'STATUS="' + @STATUS + '" SERVICE="' + @SERVICE + '" />'

		INSERT INTO dbo.ClientChangeTable(ClientID, OldValue, NewValue)
			SELECT @ID, @OLD, NULL
		
		FETCH NEXT FROM CL INTO
			@ID, @FULL, @ADDRESS, @INN, @DIR, @DIR_PHONE, @BUH, @BUH_PHONE, @RES, @RES_PHONE, @RES_POS, @STATUS, @SERVICE
	END
END