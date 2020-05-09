USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Maintenance].[UserlogSessionView]
AS
	SELECT ID, USR, COMP, DT_SHORT AS S_DAY, DT AS S_START, S_END, DATEDIFF(MINUTE, DT, S_END) AS WORK_TIME
	FROM
		(
			SELECT ID, USR, COMP, DT_SHORT, DT,
				(
					SELECT TOP 1 b.DT
					FROM Maintenance.Userlog b
					WHERE a.USR = b.USR
						AND a.COMP = b.COMP
						AND b.OPER = 'Вышел'
						AND a.DT_SHORT = b.DT_SHORT
						AND b.DT > a.DT
					ORDER BY DT
				) AS S_END
			FROM Maintenance.Userlog a
			WHERE OPER = 'Зашел'
		) AS o_O
	WHERE S_END IS NOT NULL
GO
