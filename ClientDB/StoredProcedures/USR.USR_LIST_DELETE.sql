USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USR_LIST_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[USR_LIST_DELETE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [USR].[USR_LIST_DELETE]
	@ID NVARCHAR(MAX)
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

		DECLARE @USR TABLE(ID INT)

		INSERT INTO @USR(ID)
			SELECT ID
			FROM dbo.TableIDFromXML(@ID)

		DELETE
		FROM USR.USRUpdates
		WHERE UIU_ID_IB IN
			(
				SELECT UI_ID
				FROM USR.USRIB
				WHERE UI_ID_USR IN
						(
							SELECT ID
							FROM @USR
						)
			)

		DELETE
		FROM USR.USRIB
		WHERE UI_ID_USR IN
			(
				SELECT ID
				FROM @USR
			)

		DELETE
		FROM USR.USRPackage
		WHERE UP_ID_USR IN
			(
				SELECT ID
				FROM @USR
			)

		DELETE
		FROM USR.USRFileData
		WHERE UF_ID IN
			(
				SELECT ID
				FROM @USR
			)

		DELETE
		FROM USR.USRFileTech
		WHERE UF_ID IN
			(
				SELECT ID
				FROM @USR
			)

		DELETE
		FROM USR.USRFile
		WHERE UF_ID IN
			(
				SELECT ID
				FROM @USR
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[USR_LIST_DELETE] TO rl_maintenance;
GO
