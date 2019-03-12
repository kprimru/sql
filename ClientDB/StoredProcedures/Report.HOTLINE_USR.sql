USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Report].[HOTLINE_USR]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
		ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientFullName AS [Клиент], 
		b.DistrStr AS [Дистрибутив], b.DistrTypeName AS [Сеть], 
		T.UF_HOTLINE AS [Дата-время файла в комплекте клиента], 
		SET_DATE AS [Дата-время подключения клиента к чату],
		dbo.DateOf(
			(
				SELECT MAX(FIRST_DATE)
				FROM 
					dbo.HotlineChat z
					INNER JOIN dbo.SystemTable y ON z.SYS = y.SystemNumber
				WHERE z.DISTR = b.DISTR AND z.COMP = b.COMP AND y.HostID = b.HostID
			)) AS [Последний сеанс чата]
	FROM 
		USR.USRComplectNumberView a WITH(NOEXPAND)
		INNER JOIN USR.USRData c ON a.UD_ID = c.UD_ID
		INNER JOIN dbo.SystemTable d ON d.SystemNumber = a.UD_SYS
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON d.HostID = b.HostID AND a.UD_DISTR = b.DISTR AND a.UD_COMP = b.COMP
		INNER JOIN Din.NetType n ON n.NT_ID_MASTER = b.DistrTypeID
		INNER JOIN dbo.ClientView e WITH(NOEXPAND) ON e.ClientID = c.UD_ID_CLIENT
		INNER JOIN USR.USRActiveView f ON f.UD_ID = c.UD_ID
		INNER JOIN USR.USRFile g ON g.UF_ID = f.UF_ID
		INNER JOIN UST.USTFileTech t ON g.UF_ID = t.UF_ID
		INNER JOIN dbo.HotlineDistr h ON h.ID_HOST = b.HostID AND h.DISTR = b.DISTR AND h.COMP = b.COMP
	WHERE c.UD_ACTIVE = 1 AND h.UNSET_DATE IS NULL 
		AND b.DS_REG = 0
		AND n.NT_TECH IN (0, 1)
		AND 
			(
				T.UF_HOTLINE IS NULL AND T.UF_FORMAT >= 11
				OR
				T.UF_HOTLINE_KIND IN ('N')
			)	
	ORDER BY ManagerName, ServiceName, ClientFullname
END
