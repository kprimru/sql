﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DistrCoef]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[DistrCoef] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[DistrCoef]
(
	@SYS	INT,
	@NET	INT,
	@TYPE	NVARCHAR(128),
	@DATE	SMALLDATETIME
)
RETURNS DECIMAL(8, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(8, 4)

	DECLARE @PERIOD	UNIQUEIDENTIFIER

	SELECT @PERIOD = ID
	FROM Common.Period
	WHERE @DATE BETWEEN START_REPORT AND FINISH_REPORT AND TYPE = 2

	DECLARE @SYS_REG	NVARCHAR(32)

	SELECT @SYS_REG = SystemBaseName
	FROM dbo.SystemTable
	WHERE SystemID = @SYS

	SELECT @RES =
		CASE

			WHEN NT_TECH = 3 AND @SYS_REG IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP',
													'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZO', 'SKZB') THEN 1.1
			WHEN NT_TECH = 3 AND @SYS_REG IN ('SKBEM', 'SBOEM', 'SKJEM', 'SKUEM') THEN 1
			WHEN NT_TECH = 9 AND NT_NET = 1 AND @SYS_REG IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN 1.25
			WHEN NT_TECH = 9 AND NT_NET = 2 AND @SYS_REG IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN 1.5
			WHEN NT_TECH = 9 AND NT_NET = 3 AND @SYS_REG IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN 2
			WHEN NT_TECH = 9 AND NT_NET = 5 AND @SYS_REG IN ('SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO') THEN 3
			WHEN NT_TECH = 11 AND NT_ODON != 5 AND @SYS_REG IN ('SKBO', 'SKUO', 'SBOO', 'SKJP', 'SKZO', 'SKZB') THEN 1.3
			WHEN NT_TECH = 11 AND NT_ODON != 5 AND @SYS_REG IN ('SKUP', 'SBOP') THEN 1.5
			WHEN NT_TECH = 13 AND NT_ODON = 5 AND @SYS_REG IN ('SKUP', 'SBOP') THEN 2.3
			WHEN NT_TECH = 13 AND NT_ODON = 10 AND @SYS_REG IN ('SKUP', 'SBOP') THEN 2.52
			WHEN NT_TECH = 13 AND NT_ODON = 20 AND @SYS_REG IN ('SKUP', 'SBOP') THEN 2.64
			WHEN NT_TECH = 13 AND NT_ODON = 50 AND @SYS_REG IN ('SKUP', 'SBOP') THEN 2.86
			ELSE COEF
		END
	FROM
		dbo.DistrTypeCoef b
		--INNER JOIN dbo.DistrTypeTable ON ID_NET = DistrTypeID
		INNER JOIN Din.NetType ON NT_ID_MASTER = ID_NET
	WHERE ID_MONTH = @PERIOD AND ID_NET = @NET

	RETURN @RES
END
GO
