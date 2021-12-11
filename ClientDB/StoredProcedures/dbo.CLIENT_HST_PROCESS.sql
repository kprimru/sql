USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_HST_PROCESS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_HST_PROCESS]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_HST_PROCESS]
	@PATH			NVARCHAR(512),
	@SIZE			BIGINT,
	@DATE			DATETIME,
	@MD5			NVARCHAR(128),
	@CLIENT			INT,
	@SEARCH_DATA	NVARCHAR(MAX),
	@RC				INT = NULL OUTPUT
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

		INSERT INTO dbo.ClientHST(PATH, FILE_DATE, FILE_MD5, FILE_SIZE)
			SELECT @PATH, @DATE, @MD5, @SIZE
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientHST
					WHERE FILE_DATE = @DATE
						AND FILE_MD5 = @MD5
						AND FILE_SIZE = @SIZE
				)

		EXEC dbo.CLIENT_SEARCH_PROCESS @CLIENT, @SEARCH_DATA, @RC OUTPUT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_HST_PROCESS] TO rl_hst_process;
GO
