USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DISTR_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DISTR_INSERT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_DISTR_INSERT]
	@CLIENT	INT,
	@SYSTEM	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@STYPE	INT,
	@DTYPE	INT,
	@STATUS	UNIQUEIDENTIFIER,
	@BEGIN	SMALLDATETIME,
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.ClientDistr(ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE)
			OUTPUT inserted.ID INTO @TBL
			SELECT @CLIENT, HostID, @SYSTEM, @DISTR, @COMP, @STYPE, @DTYPE, @STATUS, @BEGIN
			FROM dbo.SystemTable
			WHERE SystemID = @system

		SELECT @ID = ID FROM @TBL

		IF (SELECT SystemBaseName FROM dbo.SystemTable WHERE SystemID = @SYSTEM) != 'SKS' BEGIN
			EXEC [dbo].[ClientStudyClaim@Create?Auto]
				@Client_Id		= @CLIENT,
				@Reason			= 'Новый дистрибутив',
				@CreateClaim	= 1,
				@FillPersonal	= 1;
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_INSERT] TO rl_client_distr_i;
GO
