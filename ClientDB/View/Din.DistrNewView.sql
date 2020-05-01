USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Din].[DistrNewView]
AS
	SELECT
		DF_ID, DF_DISTR, DF_COMP, DF_RIC, dbo.DateOf(DF_CREATE) AS DF_CREATE,
		b.SST_REG, c.NT_NET, c.NT_TECH, d.SystemBaseName, SystemOrder
	FROM
		Din.DinFiles a
		INNER JOIN Din.SystemType b ON a.DF_ID_TYPE = b.SST_ID
		INNER JOIN Din.NetType c ON c.NT_ID = a.DF_ID_NET
		INNER JOIN dbo.SystemTable d ON d.SystemID = a.DF_ID_SYS
	WHERE NOT EXISTS
		(
			SELECT *
			FROM
				Din.DinFiles z
				INNER JOIN dbo.SystemTable y ON z.DF_ID_SYS = y.SystemID
			WHERE y.HostID = d.HostID
				AND z.DF_DISTR = a.DF_DISTR
				AND z.DF_COMP = a.DF_COMP
				AND	z.DF_ID <> a.DF_ID
		) AND
		NOT EXISTS
		(
			SELECT *
			FROM
				Din.DinFiles z
				INNER JOIN dbo.SystemTable y ON z.DF_ID_SYS = y.SystemID
				INNER JOIN dbo.DistrExchange x ON x.OLD_HOST = y.HostID
											AND x.OLD_NUM = z.DF_DISTR
											AND x.OLD_NUM = z.DF_COMP
			WHERE x.NEW_HOST = d.HostID
				AND x.NEW_NUM = a.DF_DISTR
				AND x.NEW_COMP = a.DF_COMP
				AND z.DF_ID <> a.DF_ID
		) AND NOT EXISTS
		(
			SELECT *
			FROM
				Reg.RegDistr z
				INNER JOIN Reg.RegHistory y ON y.ID_DISTR = z.ID
			WHERE z.ID_HOST = d.HostID
				AND z.DISTR = a.DF_DISTR
				AND z.COMP = a.DF_COMP
				AND y.DATE < a.DF_CREATE
		)
