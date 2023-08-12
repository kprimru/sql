USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_SYSTEM_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_SYSTEM_INSERT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_SYSTEM_INSERT]
	@CLIENT	INT,
	@SYSTEM	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@STYPE	INT,
	@DTYPE	INT,
	@STATUS	UNIQUEIDENTIFIER,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@ID		INT = NULL OUTPUT
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

		INSERT INTO dbo.ClientSystemsTable(
					ClientID, SystemID, SystemDistrNumber, CompNumber, SystemTypeID, DistrTypeID, DistrStatusID
				)
			VALUES(@CLIENT, @SYSTEM, @DISTR, @COMP, @STYPE, @DTYPE, @STATUS)

		SELECT @ID = SCOPE_IDENTITY()

		IF ((@BEGIN IS NOT NULL) OR (@END IS NOT NULL)) AND @ID IS NOT NULL
		BEGIN
			INSERT INTO dbo.ClientSystemDatesTable(IDMaster, SystemBegin, SystemEnd)
			VALUES (@ID, @BEGIN, @END)
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
GRANT EXECUTE ON [dbo].[CLIENT_SYSTEM_INSERT] TO rl_client_system_i;
GO
