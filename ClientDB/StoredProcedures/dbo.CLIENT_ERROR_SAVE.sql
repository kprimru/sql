﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_ERROR_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_ERROR_SAVE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_ERROR_SAVE]
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT,
	@CLIENT	INT,
	@NOTE	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF @ID IS NULL
			INSERT INTO dbo.ClientError(ID_CLIENT, NOTE)
				VALUES(@CLIENT, @NOTE)
		ELSE
		BEGIN
			INSERT INTO dbo.ClientError(ID_MASTER, ID_CLIENT, NOTE, STATUS, UPD_DATE, UPD_USER)
				SELECT @ID, ID_CLIENT, NOTE, 2, UPD_DATE, UPD_USER
				FROM dbo.ClientError
				WHERE ID = @ID

			UPDATE dbo.ClientError
			SET NOTE		=	@NOTE,
				UPD_DATE	=	GETDATE(),
				UPD_USER	=	ORIGINAL_LOGIN()
			WHERE ID = @ID
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_ERROR_SAVE] TO rl_client_error_w;
GO
