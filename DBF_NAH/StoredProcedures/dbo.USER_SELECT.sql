USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[USER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[USER_SELECT]  AS SELECT 1')
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[USER_SELECT]
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

		IF OBJECT_ID('tempdb..#user') IS NOT NULL
			DROP TABLE #user

		CREATE TABLE #user
			(
				UserName VARCHAR(100),
				GroupName VARCHAR(100),
				LoginName VARCHAR(100),
				DefDBName VARCHAR(100),
				DefSchemaName VARCHAR(100),
				UserID INT,
				SID VARBINARY(1000)
			)

		INSERT INTO #user
			EXEC sp_helpuser

		SELECT DISTINCT UserName
		FROM #user
		WHERE UserName NOT IN
			(
				SELECT 'dbo'
				UNION ALL
				SELECT 'sys'
				UNION ALL
				SELECT 'guest'
				UNION ALL
				SELECT 'INFORMATION_SCHEMA'
			)
		ORDER BY UserName

		IF OBJECT_ID('tempdb..#user') IS NOT NULL
			DROP TABLE #user

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[USER_SELECT] TO rl_user;
GO
