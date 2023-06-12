USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Ric].[VKSPGet]', 'FN') IS NULL EXEC('CREATE FUNCTION [Ric].[VKSPGet] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Ric].[VKSPGet]
(
	@PR_ALG			SMALLINT,
	@PR_ID			SMALLINT,
	@PR_SYS_COEF	SMALLINT,
	@PR_NET_COEF	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES	DECIMAL(10, 4)

	DECLARE @PR_DATE	SMALLDATETIME

	SELECT @PR_DATE = PR_DATE
	FROM dbo.PeriodTable
	WHERE PR_ID = @PR_ALG

	IF @PR_DATE >= '20120601'
	BEGIN
		SELECT @RES = SUM(SW_WEIGHT * SNCC_WEIGHT)
		FROM
			(
				SELECT
					REG_ID_SYSTEM, REG_ID_NET,
					CONVERT(BIT,
						CASE
							WHEN SYS_PROBLEM = 1
								AND NOT EXISTS
								(
									SELECT *
									FROM
										dbo.PeriodRegExceptView b
										INNER JOIN dbo.DistrStatusTable ON DS_ID = b.REG_ID_STATUS
										INNER JOIN dbo.SystemProblem ON SP_ID_SYSTEM = a.REG_ID_SYSTEM
																	AND b.REG_ID_SYSTEM = SP_ID_OUT
																	AND SP_ID_PERIOD = b.REG_ID_PERIOD
									WHERE a.REG_COMPLECT = b.REG_COMPLECT
										AND a.REG_ID_PERIOD = b.REG_ID_PERIOD
										AND DS_REG = 0 AND REG_ID_TYPE <> 6
										AND a.REG_ID_SYSTEM <> b.REG_ID_SYSTEM
								) AND EXISTS
								(
									SELECT *
									FROM dbo.SystemProblem
									WHERE SP_ID_SYSTEM = a.REG_ID_SYSTEM
										AND SP_ID_PERIOD = a.REG_ID_PERIOD
								) THEN 1
							WHEN SYS_PROBLEM = 2
								AND REG_ID_TYPE IN (20, 22) THEN 1
							ELSE 0
						END) AS REG_PROBLEM
				FROM
					dbo.PeriodRegExceptView a
					INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
					INNER JOIN dbo.SystemTypeVKSP ON SSTV_ID_SST = REG_ID_TYPE
													AND SSTV_ID_PERIOD = @PR_ID
					INNER JOIN
						(
							SELECT
								SYS_ID,
								CASE
									WHEN EXISTS
										(
											SELECT * FROM dbo.SystemProblem WHERE SP_ID_SYSTEM = SYS_ID
										) THEN 1
									WHEN SYS_REG_NAME IN ('BBKZ', 'UMKZ', 'UBKZ', 'SPK-I', 'SPK-II', 'SPK-III', 'SPK-IV', 'SPK-V') THEN 2
									ELSE 0
								END AS SYS_PROBLEM
							FROM dbo.SystemTable
						) AS z ON z.SYS_ID = REG_ID_SYSTEM
				WHERE REG_ID_PERIOD = @PR_ID
					AND DS_REG = 0
			) AS t
			INNER JOIN dbo.SystemWeightTable ON SW_ID_SYSTEM = REG_ID_SYSTEM
											AND SW_ID_PERIOD = @PR_SYS_COEF
											AND SW_PROBLEM = REG_PROBLEM
			INNER JOIN dbo.SystemNetCountTable ON REG_ID_NET = SNC_ID
			INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
			INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID AND SNCC_ID_PERIOD = @PR_NET_COEF
	END

	RETURN @RES
END
GO
