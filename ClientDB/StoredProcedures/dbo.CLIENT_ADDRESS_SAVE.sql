USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_ADDRESS_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_ADDRESS_SAVE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_ADDRESS_SAVE]
	@CLIENT		INT,
	@TYPE		UNIQUEIDENTIFIER,
	@NAME		VARCHAR(150),
	@INDEX		VARCHAR(20),
	@STREET		UNIQUEIDENTIFIER,
	@HOME		VARCHAR(50),
	@OFFICE		VARCHAR(100),
	@HINT		VARCHAR(MAX),
	@NOTE		VARCHAR(MAX),
	@DISTRICT	UNIQUEIDENTIFIER = NULL,
	@MAP		VARBINARY(MAX) = NULL
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

		INSERT INTO dbo.ClientAddress(CA_ID_CLIENT, CA_ID_TYPE, CA_NAME, CA_INDEX, CA_ID_STREET, CA_HOME, CA_OFFICE, CA_HINT, CA_NOTE, CA_ID_DISTRICT)
			VALUES(@CLIENT, @TYPE, @NAME, @INDEX, @STREET, @HOME, @OFFICE, @HINT, @NOTE, @DISTRICT)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_ADDRESS_SAVE] TO rl_client_save;
GO
