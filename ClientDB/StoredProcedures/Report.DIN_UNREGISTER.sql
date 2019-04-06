USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[DIN_UNREGISTER]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		dbo.DistrString(SystemShortName, DF_DISTR, DF_COMP) AS [Дистрибутив],
		NT_SHORT AS [Сеть], SST_SHORT AS [Тип], dbo.DateOf(DF_CREATE) AS [Получен],
		dbo.DistrWeight(SystemID, DistrTypeID, SystemTypeName, dbo.MonthOf(GETDATE())) AS [Вес]
	FROM
		(
			SELECT DISTINCT 
				--HostID, DF_DISTR, DF_COMP,
				(
					SELECT TOP 1 DF_ID
					FROM 
						Din.DinFiles z
						INNER JOIN dbo.SystemTable y ON z.DF_ID_SYS = y.SystemID
					WHERE y.HostID = b.HostID
						AND z.DF_DISTR = a.DF_DISTR
						AND z.DF_COMP = a.DF_COMP
					ORDER BY DF_CREATE DESC
				) AS DF_ID
			FROM 
				Din.DinFiles a
				INNER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
			WHERE NOT EXISTS
				(
					SELECT *
					FROM 
						dbo.RegNodeTable z
						INNER JOIN dbo.SystemTable y ON z.SystemName = y.SystemBaseName
					WHERE y.HostID = b.HostID
						AND z.DistrNumber = DF_DISTR
						AND z.CompNumber = DF_COMP
				) AND DF_RIC = 20
		) AS a
		INNER JOIN Din.DinFiles b ON a.DF_ID = b.DF_ID
		INNER JOIN dbo.SystemTable c ON c.SystemID = b.DF_ID_SYS
		INNER JOIN Din.NetType d ON d.NT_ID = b.DF_ID_NET
		INNER JOIN Din.SystemType e ON e.SST_ID = b.DF_ID_TYPE
		INNER JOIN dbo.DistrTypeTable f ON f.DistrTypeID = NT_ID_MASTER
		INNER JOIN dbo.SystemTypeTable g ON g.SystemTypeID = SST_ID_MASTER
	WHERE /*NT_SHORT <> 'мобильная' AND */DATEDIFF(MONTH, DF_CREATE, GETDATE()) <= 6 AND SST_SHORT <> 'ДСП'
	ORDER BY /*SST_SHORT, */SystemOrder, DF_DISTR, DF_COMP
END
