USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[SYS_INFO_BANK_ALL_MAIN]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[SYS_INFO_BANK_ALL_MAIN]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Report].[SYS_INFO_BANK_ALL_MAIN]
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

		DECLARE @t	TABLE(SysBaseName	NVARCHAR(MAX), DistrTypeName	NVARCHAR(MAX), Banks	NVARCHAR(MAX), SystemOrder	INT, BanksCount	INT)

		INSERT INTO @t
		SELECT
				SystemBaseName , DistrTypeName,
				REVERSE(STUFF(REVERSE((
				SELECT InfoBankName + ', '
				FROM dbo.SystemInfoBanksView b WITH(NOEXPAND)
				WHERE b.System_ID = a.System_ID AND b.DistrType_ID = a.DistrType_ID
				ORDER BY InfoBankName
				FOR XML PATH('')
				)), 1, 2, '')) AS Banks,
				SystemOrder,
				(SELECT COUNT(*)
				FROM dbo.SystemInfoBanksView b WITH(NOEXPAND)
				WHERE b.System_ID = a.System_ID AND b.DistrType_ID = a.DistrType_ID) AS BanksCount
		FROM dbo.SystemInfoBanksView a WITH(NOEXPAND)
		WHERE SystemActive = 1 AND HostID = 1
		GROUP BY SystemBaseName, DistrTypeName, a.System_ID, a.DistrType_ID, SystemOrder

		SELECT
				SysBaseName + ' : ' +
				REVERSE(STUFF(REVERSE((
				SELECT DistrTypeName + ', '
				FROM @t t2
				WHERE t2.SysBaseName = t1.SysBaseName AND t2.Banks = t1.Banks
				ORDER BY DistrTypeName
				FOR XML PATH('')
				)), 1, 2, '')) AS Systems,
				Banks,
				SystemOrder,
				BanksCount
		FROM @t t1
		GROUP BY SysBaseName, Banks, SystemOrder, BanksCount
		ORDER BY SystemOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END



GO
