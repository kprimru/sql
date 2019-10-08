USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[SYS_INFO_BANK_ALL_MAIN]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @t	TABLE(SysBaseName	NVARCHAR(MAX), DistrTypeName	NVARCHAR(MAX), Banks	NVARCHAR(MAX), SystemOrder	INT)

	INSERT INTO @t
	SELECT 
			SystemBaseName , DistrTypeName,
			REVERSE(STUFF(REVERSE(( 
			SELECT InfoBankName + ', '
			FROM dbo.SystemInfoBanksView b
			WHERE b.System_ID = a.System_ID AND b.DistrType_ID = a.DistrType_ID
			ORDER BY InfoBankName
			FOR XML PATH('') 
			)), 1, 2, '')) AS Banks,
			SystemOrder
	FROM dbo.SystemInfoBanksView a
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
			SystemOrder
	FROM @t t1
	GROUP BY SysBaseName, Banks, SystemOrder
	ORDER BY SystemOrder
END

