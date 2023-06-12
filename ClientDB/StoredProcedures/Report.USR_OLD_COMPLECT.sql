USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[USR_OLD_COMPLECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[USR_OLD_COMPLECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[USR_OLD_COMPLECT]
	@PARAM	NVARCHAR(MAX) = NULL
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

		SELECT Sys1 AS [Старая система], Sys2 AS [Новая система], UD_DISTR AS [Номер дистрибутива], UD_COMP AS [Номер комп], MAX_DATE AS [Дата последнего файла USR]
		FROM
			(
				SELECT
					Sys1, Sys2, UD_DISTR, UD_COMP,
					(
								SELECT TOP 1 UF_DATE
								FROM USR.USRFile
								WHERE UF_ID_COMPLECT = UD_ID
								ORDER BY UF_DATE DESC
					) AS MAX_DATE
				FROM
					(
						SELECT
							b.SystemShortName AS Sys1, c.SystemShortName AS Sys2, a.UD_DISTR, a.UD_COMP,
							e.UD_ID
						FROM
							USR.USRComplectNumberView a WITH(NOEXPAND)
							INNER JOIN dbo.SystemTable b ON a.UD_SYS = b.SystemNumber
							INNER JOIN dbo.SystemTable c ON c.HostID = b.HostID AND b.SystemNumber <> c.SystemNumber
							INNER JOIN USR.USRComplectNumberView d WITH(NOEXPAND) ON d.UD_SYS = c.SystemNumber AND a.UD_DISTR = d.UD_DISTR AND a.UD_COMP = d.UD_COMP
							INNER JOIN USR.USRData e ON e.UD_ID = a.UD_ID
							INNER JOIN USR.USRData f ON f.UD_ID = d.UD_ID
						WHERE e.UD_ACTIVE = 1 AND f.UD_ACTIVE = 1 AND f.UD_ID_CLIENT IS NOT NULL AND e.UD_ID_CLIENT IS NOT NULL
					) AS o_O
			) AS o_O
		WHERE MAX_DATE <= DATEADD(MONTH, -2, GETDATE())
		ORDER BY UD_DISTR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Report].[USR_OLD_COMPLECT] TO rl_report;
GO
