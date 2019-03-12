USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Report].[ZVE_USR]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
		ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientFullName AS [Клиент], 
		b.DistrStr AS [Дистрибутив], b.DistrTypeName AS [Сеть], 
		T.UF_EXPCONS AS [Дата-время файла в комплекте клиента], 
		SET_DATE AS [Дата-время подключения клиента в кнопке ЗВЭ],
		dbo.DateOf(
			(
				SELECT MAX(DATE)
				FROM 
					dbo.ClientDutyQuestion z
					INNER JOIN dbo.SystemTable y ON z.SYS = y.SystemNumber
				WHERE z.DISTR = b.DISTR AND z.COMP = b.COMP AND y.HostID = b.HostID
			)
		) AS [Дата последнего вопроса]
	FROM 
		USR.USRComplectNumberView a WITH(NOEXPAND)
		INNER JOIN USR.USRData c ON a.UD_ID = c.UD_ID
		INNER JOIN dbo.SystemTable d ON d.SystemNumber = a.UD_SYS
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON d.HostID = b.HostID AND a.UD_DISTR = b.DISTR AND a.UD_COMP = b.COMP
		INNER JOIN Din.NetType n ON n.NT_ID_MASTER = b.DistrTypeID
		INNER JOIN dbo.ClientView e WITH(NOEXPAND) ON e.ClientID = c.UD_ID_CLIENT
		INNER JOIN USR.USRActiveView f ON f.UD_ID = c.UD_ID
		INNER JOIN USR.USRFile g ON g.UF_ID = f.UF_ID
		INNER JOIN USR.USRFileTech t ON t.UF_ID = g.UF_ID
		INNER JOIN dbo.ExpDistr h ON h.ID_HOST = b.HostID AND h.DISTR = b.DISTR AND h.COMP = b.COMP
	WHERE c.UD_ACTIVE = 1 AND h.UNSET_DATE IS NULL 
		AND n.NT_TECH IN (0, 1)
		AND 
			(
				T.UF_EXPCONS IS NULL AND T.UF_FORMAT >= 11
				OR
				T.UF_EXPCONS_KIND IN ('N')
			)	
	ORDER BY ManagerName, ServiceName, ClientFullname
END
