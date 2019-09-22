USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[SYS_INFO_BANK_ALL]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SystemBaseName + ', ' + DistrTypeName AS Sys_Distr,
			REVERSE(STUFF(REVERSE(( 
			SELECT InfoBankName + ', '
			FROM dbo.SystemInfoBanksView b
			WHERE b.System_ID = a.System_ID AND b.DistrType_ID = a.DistrType_ID
			ORDER BY InfoBankName
			FOR XML PATH('') 
			)), 1, 2, '')) AS Banks
	FROM dbo.SystemInfoBanksView a
	--WHERE DistrType_ID = 2 OR DistrType_ID = 16 OR DistrType_ID = 17 OR DistrType_ID = 1

	GROUP BY SystemBaseName + ', ' + DistrTypeName, a.System_ID, a.DistrType_ID

END

