USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USR_FILE_HASH_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[USR_FILE_HASH_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [USR].[USR_FILE_HASH_SELECT]
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

		DECLARE @Files TABLE
		(
			UF_ID	INT	PRIMARY KEY CLUSTERED,
			UF_NAME	NVARCHAR(256)
		);


		INSERT INTO @Files
		SELECT TOP 1000
			UF_ID, UF_NAME
		FROM USR.USRFile
		WHERE UF_HASH IS NULL;

		SELECT F.UF_ID, F.UF_NAME, D.UF_DATA
		FROM @Files F
		INNER JOIN USR.USRFileData D ON F.UF_ID = D.UF_ID
		OPTION (RECOMPILE);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [USR].[USR_FILE_HASH_SELECT] TO rl_usr_process;
GO
