USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ONLINE_TECH_REPORT]
	@PARAM NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @HST_LAW INT
	SELECT @HST_LAW = HostID FROM dbo.Hosts WHERE HostReg = 'LAW'

	SELECT DistrStr AS [Дистрибутив], SST_SHORT AS [Тип], NT_SHORT AS [Сеть], Comment AS [Клиент], 'Дополнительная система без основной' AS [Примечание]
	FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
	WHERE HostID <> @HST_LAW
		AND NT_TECH > 1
		AND DS_REG = 0
		AND a.Complect IS NOT NULL
		AND NOT EXISTS
			(
				SELECT *
				FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
				WHERE z.Complect = a.Complect
					AND z.DS_REG = 0
					AND z.HostID = @HST_LAW
			)

	UNION ALL
			
	SELECT DistrStr, SST_SHORT, NT_SHORT, Comment, 'Не совпадают типы онлайн'
	FROM 
		Reg.RegNodeSearchView a WITH(NOEXPAND)	
	WHERE NT_TECH > 1
		AND DS_REG = 0
		AND a.Complect IS NOT NULL
		AND EXISTS
			(
				SELECT *
				FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
				WHERE z.Complect = a.Complect
					AND z.DS_REG = 0
					AND z.NT_TECH <> a.NT_TECH
			)
	ORDER BY [Клиент]
END
