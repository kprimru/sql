USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[INFO_COD]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		DistrStr AS [Осн. дистрибутив], 
		Client AS [Клиента], Manager AS [Рук-ль / подхост], 
		ServiceName AS [СИ], 
		UF_CREATE AS [USR получен], UF_INFO_COD AS [Дата файла info.cod]		
	FROM
		(
			SELECT DISTINCT 	
				CASE 
					WHEN ServiceName IS NULL THEN 0 
					ELSE 1 
				END AS TP, 
				T.UF_INFO_COD, g.DistrStr, UD_DISTR, UD_COMP,
				ISNULL(ClientFullName, h.Comment) AS Client, ServiceName, 
				ISNULL(ManagerName, SubhostName) AS Manager, d.SystemOrder, a.UF_CREATE
			FROM 
				USR.USRActiveView a
				INNER JOIN USR.USRFile b ON a.UF_ID = b.UF_ID
				INNER JOIN USR.USRFileTech t ON t.UF_ID = b.UF_ID
				INNER JOIN dbo.SystemTable d ON a.UF_ID_SYSTEM = d.SystemID
				LEFT OUTER JOIN dbo.ClientDistrView e WITH(NOEXPAND) ON d.SystemID = e.SystemID AND DISTR = UD_DISTR AND COMP = UD_COMP
				LEFT OUTER JOIN dbo.ClientView f WITH(NOEXPAND) ON ClientID = ID_CLIENT
				LEFT OUTER JOIN dbo.RegNodeCurrentView g WITH(NOEXPAND) ON g.SystemID = d.SYstemID AND UD_DISTR = DistrNumber AND UD_COMP = CompNumber
				LEFT OUTER JOIN dbo.RegNodeTable h ON h.ID = g.ID
			WHERE b.UF_CREATE >= DATEADD(MONTH, -2, GETDATE())
				AND t.UF_INFO_COD IS NOT NULL
				AND h.ID IS NOT NULL
		) AS o_O
	ORDER BY 
		TP, Manager, ServiceName, Client, SystemOrder, UD_DISTR, UD_COMP
END
