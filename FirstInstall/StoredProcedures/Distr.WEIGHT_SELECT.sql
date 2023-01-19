﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Distr].[WEIGHT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Distr].[WEIGHT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Distr].[WEIGHT_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		WG_ID,
		SYS_ID_MASTER, SYS_SHORT,
		WG_ID_MASTER, WG_NAME,
		WG_VALUE, WG_DATE, WG_END
	FROM
		[Distr].[WeightActive]	INNER JOIN
		[Distr].[SystemLast]	ON SYS_ID_MASTER = WG_ID_SYSTEM

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Distr].[WEIGHT_SELECT] TO rl_weight_r;
GO
