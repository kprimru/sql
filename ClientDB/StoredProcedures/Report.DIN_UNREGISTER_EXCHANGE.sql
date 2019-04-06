USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[DIN_UNREGISTER_EXCHANGE]
	@PARAM NVARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ISNULL(ClientFullName, Comment) AS [Клиент], ISNULL(ManagerName, SubhostName) AS [Рук-ль], ServiceName AS [СИ], c.DistrStr AS [Текущий дистрибутив], c.NT_SHORT AS [Текущая сетевитость], 
		CASE 
			WHEN b.SystemShortName <> c.SystemShortName THEN
				CASE
					WHEN b.NT_SHORT <> c.NT_SHORT THEN b.SystemShortName + ' (' + b.NT_SHORT + ')'
					ELSE b.SystemShortName
				END
			ELSE
				b.NT_SHORT
		END AS [Дистрибутив-замена],
		--b.SystemShortName, b.NT_SHORT, 
		b.DF_CREATE AS [Дата поступления дистрибутива]
	FROM
		(
			SELECT HostID, DF_DISTR, DF_COMP, MAX(DF_CREATE) AS DF_CREATE
			FROM Din.DinView WITH(NOEXPAND)
			GROUP BY HostID, DF_DISTR, DF_COMP
		) AS a
		INNER JOIN Din.DinView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DF_DISTR = b.DF_DISTR AND a.DF_COMP = b.DF_COMP AND a.DF_CREATE = b.DF_CREATE
		INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DistrNumber = b.DF_DISTR AND c.CompNumber = b.DF_COMP
		LEFT OUTER JOIN dbo.ClientDistrView d WITH(NOEXPAND) ON d.HostID = c.HostID AND d.DISTR = c.DistrNumber AND d.COMP = c.CompNumber
		LEFT OUTER JOIN dbo.ClientView e WITH(NOEXPAND) ON e.ClientID = d.ID_CLIENT
	WHERE c.DS_REG = 0
		AND b.DF_CREATE >= DATEADD(MONTH, -6, GETDATE())
		AND
			(
				c.NT_SHORT <> b.NT_SHORT OR c.SystemShortName <> b.SystemShortName
			)
	ORDER BY b.DF_CREATE DESC, c.SystemOrder, DistrNumber, CompNumber
END
