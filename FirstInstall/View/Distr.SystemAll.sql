USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Distr].[SystemAll]
--WITH SCHEMABINDING
AS
	SELECT
		SYS_ID_MASTER, SYS_ID, SYS_ID_HOST,
		SYS_NAME, SYS_SHORT, SYS_REG, SYS_ORDER, SYS_WEIGHT,
		CASE 
			WHEN EXISTS(
				SELECT *
				FROM Distr.WeightActive
				WHERE WG_ID_SYSTEM = SYS_ID_MASTER
			) THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
		END AS SYS_MAIN,
		SYS_DATE, SYS_END, SYS_REF
	FROM
		Distr.SystemDetailGO
