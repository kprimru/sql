USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientLargeView]
AS
	SELECT ClientID
	FROM dbo.ClientView a WITH(NOEXPAND)
	WHERE a.ServiceStatusID = 2
		AND EXISTS
			(
				SELECT *
				FROM dbo.ClientDistrView z WITH(NOEXPAND)
				INNER JOIN Din.NetType y ON z.DistrTypeId = y.NT_ID_MASTER
				WHERE z.ID_CLIENT = a.ClientID
					AND DS_REG = 0
					AND SystemTypeName IN ('����� �', '������������', '����� �')
					AND
						(
							z.HostID = 1
							AND
							y.NT_NET > 1

							OR

							y.NT_NET = 1
							AND
							z.SystemBaseName IN ('LAW', 'BVP', 'BUDP', 'JURP')
						)
			)
