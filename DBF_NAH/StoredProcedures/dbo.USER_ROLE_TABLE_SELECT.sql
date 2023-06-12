USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[USER_ROLE_TABLE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[USER_ROLE_TABLE_SELECT]  AS SELECT 1')
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[USER_ROLE_TABLE_SELECT]
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

		IF OBJECT_ID('tempdb..#role') IS NOT NULL
		DROP TABLE #role

		CREATE TABLE #role
			(
				RNAME VARCHAR(100),
				RUSER VARCHAR(100),
				MSID VARBINARY(1000)
			)

		INSERT INTO #role EXEC sp_helprolemember

		DELETE
		FROM #role
		WHERE RUSER = 'dbo'

		DECLARE @sql VARCHAR(MAX)

		SET @sql = 'SELECT RNAME, ROLE_NOTE, '

		SELECT @sql = @sql + '[' + RUSER + '],'
		FROM
			(
				SELECT DISTINCT RUSER
				FROM #role
			) AS O_O
		ORDER BY RUSER

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + '
							FROM
								(
									SELECT ROLE_NOTE, RUSER, RNAME
									FROM
										#role INNER JOIN
										dbo.RoleTable ON ROLE_NAME = #role.RNAME
								) p
							PIVOT
								(
									COUNT (RUser) 
									FOR RUSER IN
										( '
		SELECT @sql = @sql + '[' + RUSER + '],'
		FROM
			(
				SELECT DISTINCT RUSER
				FROM #role
			) AS O_O
		ORDER BY RUSER

		SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SET @sql = @sql + '
										)
								) AS pvt
							ORDER BY RNAME'

		--PRINT (@SQL)

		EXEC (@sql)

		IF OBJECT_ID('tempdb..#role') IS NOT NULL
			DROP TABLE #role

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[USER_ROLE_TABLE_SELECT] TO rl_user;
GO
