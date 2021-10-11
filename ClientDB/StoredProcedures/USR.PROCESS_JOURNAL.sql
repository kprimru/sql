USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[PROCESS_JOURNAL]
	@DATE	DATETIME,
	@BEGIN	DATETIME,
	@END	DATETIME,
	@RES	TINYINT,
	@TXT	NVARCHAR(MAX),
	@FILE	VARCHAR(50),
	@COMP	VARCHAR(50) = NULL
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

		IF (SELECT Maintenance.GlobalUSRJournal()) = '1'
		BEGIN
			IF @DATE IS NOT NULL
			INSERT INTO USR.ProcessJournal(PR_DATE, PR_BEGIN, PR_END, PR_RES, PR_TEXT, PR_FILE, PR_COMPLECT)
				VALUES(@DATE, @BEGIN, @END, @RES, @TXT, @FILE, @COMP)
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
