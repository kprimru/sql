USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Din].[DistrExchangeView]
AS
	SELECT
		DF_ID, DF_DISTR, DF_COMP, DF_RIC, dbo.DateOf(DF_CREATE) AS DF_CREATE, b.SST_REG,
		c.NT_NET AS NEW_NET, c.NT_TECH AS NEW_TECH, d.SystemBaseName AS NEW_SYSTEM, SystemOrder,
		(
			SELECT TOP 1 SystemBaseName
			FROM
				Reg.RegDistr z
				INNER JOIN Reg.RegHistory y ON y.ID_DISTR = z.ID
				INNER JOIN dbo.SystemTable x ON x.SystemID = y.ID_SYSTEM
			WHERE z.ID_HOST = d.HostID
				AND z.DISTR = a.DF_DISTR
				AND z.COMP = a.DF_COMP
				AND y.DATE < a.DF_CREATE
			ORDER BY DATE DESC
		) AS OLD_SYSTEM,
		(
			SELECT TOP 1 NT_NET
			FROM
				Reg.RegDistr z
				INNER JOIN Reg.RegHistory y ON y.ID_DISTR = z.ID
				INNER JOIN Din.NetType x ON x.NT_ID = y.ID_NET
			WHERE z.ID_HOST = d.HostID
				AND z.DISTR = a.DF_DISTR
				AND z.COMP = a.DF_COMP
				AND y.DATE < a.DF_CREATE
			ORDER BY DATE DESC
		) AS OLD_NET,
		(
			SELECT TOP 1 NT_TECH
			FROM
				Reg.RegDistr z
				INNER JOIN Reg.RegHistory y ON y.ID_DISTR = z.ID
				INNER JOIN Din.NetType x ON x.NT_ID = y.ID_NET
			WHERE z.ID_HOST = d.HostID
				AND z.DISTR = a.DF_DISTR
				AND z.COMP = a.DF_COMP
				AND y.DATE < a.DF_CREATE
			ORDER BY DATE DESC
		) AS OLD_TECH,
		(
			SELECT TOP 1 COMMENT
			FROM
				Reg.RegDistr z
				INNER JOIN Reg.RegHistory y ON y.ID_DISTR = z.ID
			WHERE z.ID_HOST = d.HostID
				AND z.DISTR = a.DF_DISTR
				AND z.COMP = a.DF_COMP
				AND y.DATE < a.DF_CREATE
			ORDER BY DATE DESC
		) AS COMMENT,
		dbo.GET_HOST_BY_COMMENT((
			SELECT TOP 1 COMMENT
			FROM
				Reg.RegDistr z
				INNER JOIN Reg.RegHistory y ON y.ID_DISTR = z.ID
			WHERE z.ID_HOST = d.HostID
				AND z.DISTR = a.DF_DISTR
				AND z.COMP = a.DF_COMP
				AND y.DATE < a.DF_CREATE
			ORDER BY DATE DESC
		)) AS SUBHOST_REG
	FROM
		Din.DinFiles a
		INNER JOIN Din.SystemType b ON a.DF_ID_TYPE = b.SST_ID
		INNER JOIN Din.NetType c ON c.NT_ID = a.DF_ID_NET
		INNER JOIN dbo.SystemTable d ON d.SystemID = a.DF_ID_SYS
	WHERE EXISTS
		(
			SELECT *
			FROM
				Din.DinFiles z
				INNER JOIN dbo.SystemTable y ON z.DF_ID_SYS = y.SystemID
			WHERE y.HostID = d.HostID
				AND z.DF_DISTR = a.DF_DISTR
				AND z.DF_COMP = a.DF_COMP
				AND z.DF_ID <> a.DF_ID
				AND (
						z.DF_ID_SYS <> a.DF_ID_SYS
						OR a.DF_ID_NET <> a.DF_ID_NET
					)
		) OR EXISTS
		(
			SELECT *
			FROM
				Reg.RegDistr z
				INNER JOIN Reg.RegHistory y ON y.ID_DISTR = z.ID
			WHERE z.ID_HOST = d.HostID
				AND z.DISTR = a.DF_DISTR
				AND z.COMP = a.DF_COMP
				AND y.DATE < a.DF_CREATE
				AND (
						y.ID_SYSTEM <> a.DF_ID_SYS
						OR y.ID_NET <> a.DF_ID_NET
					)
		)
