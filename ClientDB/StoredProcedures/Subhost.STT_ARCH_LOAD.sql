USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[STT_ARCH_LOAD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[STT_ARCH_LOAD]  AS SELECT 1')
GO

ALTER PROCEDURE [Subhost].[STT_ARCH_LOAD]
	@SUBHOST	UNIQUEIDENTIFIER,
	@USR		NVARCHAR(128),
	@BIN		VARBINARY(MAX)
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

		INSERT INTO Subhost.STTFiles(ID_SUBHOST, USR, BIN)
			VALUES(@SUBHOST, @USR, @BIN)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[STT_ARCH_LOAD] TO rl_web_subhost;
GO
