USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[INFO_BANKS_OUT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
    SELECT DISTINCT 
		C.Comment AS [Название клиента], C.Complect AS [Комплект], rnc.DistrNumber AS [Дистрибутив], cv.ServiceName AS [СИ], cv.ManagerName AS [Руководитель],
		REVERSE(STUFF(REVERSE((
			SELECT IB.InfoBankName + ', '
			FROM dbo.ComplectGetLeftBanks(C.Complect, NULL) IB
			FOR XML PATH('')
		)), 1, 2, '')) AS [Отсутствующие банки],
		REVERSE(STUFF(REVERSE((
			SELECT IB.InfoBankShortName + ', '
			FROM dbo.ComplectGetLeftBanks(C.Complect, NULL) IB
			FOR XML PATH('')
		)), 1, 2, '')) AS [Отсутствующие банки],
		usr.UF_DATE AS [Дата файла USR]
	FROM
		(
			SELECT DISTINCT Complect, Comment, DistrNumber, CompNumber, HostID
			FROM Reg.RegNodeSearchView WITH(NOEXPAND)
			WHERE Service = 0
               AND Complect IS NOT NULL
		) C
	INNER JOIN dbo.RegNodeComplectClientView rnc  ON  rnc.DistrNumber = C.DistrNumber AND rnc.HostID = C.HostID AND rnc.CompNumber = C.CompNumber
	INNER JOIN dbo.ClientView cv WITH(NOEXPAND) ON cv.ClientID = rnc.ClientID
	CROSS APPLY dbo.ComplectGetBanks(C.Complect, NULL)
	LEFT OUTER JOIN USR.USRActiveView usr ON usr.UD_DISTR = rnc.DistrNumber AND usr.UD_COMP = rnc.CompNumber

	WHERE SubhostName = '' AND--AND (cv.ServiceName NOT IN ('УССУРИЙСК', 'АРТЕМ', 'СЛАВЯНКА'))
			usr.UF_DATE IS NOT NULL AND usr.UF_DATE <> ''
END
