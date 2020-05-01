USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Distr].[WeightActive]
--WITH SCHEMABINDING
AS
	SELECT
		WG_ID_MASTER, WG_ID, WG_ID_SYSTEM, WG_NAME,
		WG_VALUE, WG_DATE, WG_END
	FROM
		Distr.WeightAll
	WHERE WG_REF = 1