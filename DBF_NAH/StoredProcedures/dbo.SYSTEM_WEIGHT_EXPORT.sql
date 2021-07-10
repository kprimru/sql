USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_WEIGHT_EXPORT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SYS_REG_NAME, PR_STR, SW_WEIGHT, SW_PROBLEM
	FROM
		(
			SELECT
				SYS_REG_NAME, PR_STR,
				(
					SELECT SW_WEIGHT
					FROM dbo.SystemWeightTable
					WHERE SW_ACTIVE = 1
						AND SW_ID_SYSTEM = SYS_ID
						AND SW_ID_PERIOD = PR_ID
						AND SW_PROBLEM = 0
				) AS SW_WEIGHT,
				(
					SELECT SW_WEIGHT
					FROM dbo.SystemWeightTable
					WHERE SW_ACTIVE = 1
						AND SW_ID_SYSTEM = SYS_ID
						AND SW_ID_PERIOD = PR_ID
						AND SW_PROBLEM = 1
				) AS SW_PROBLEM
			FROM
				(
					SELECT SYS_REG_NAME, CONVERT(VARCHAR(20), PR_DATE, 112) AS PR_STR, PR_ID, SYS_ID
					FROM
						dbo.SystemTable
						CROSS JOIN dbo.PeriodTable
					WHERE SYS_REG_NAME IS NOT NULL AND SYS_REG_NAME <> '-' AND SYS_REG_NAME <> '--' AND SYS_ACTIVE = 1
				) AS o_O
		) AS o_O
	WHERE SW_WEIGHT IS NOT NULL OR SW_PROBLEM IS NOT NULL
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_WEIGHT_EXPORT] TO rl_system_weight_w;
GO