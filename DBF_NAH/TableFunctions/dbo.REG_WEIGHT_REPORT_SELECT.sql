USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[REG_WEIGHT_REPORT_SELECT]
(
	@PR_ID INT
)
RETURNS @TBL TABLE
	(
		HST_ID	SMALLINT,
		REG_ID_SYSTEM	SMALLINT,
		DIS_NUM	INT,
		COMP	TINYINT,
		REG_ID_TYPE	SMALLINT,
		REG_ID_TECH_TYPE	SMALLINT,
		REG_ID_HOST	SMALLINT,
		REG_ID_NET	SMALLINT,
		CNT	INT
	)
AS
BEGIN
	DECLARE @RESTORE_ACTION	SMALLINT

	SELECT @RESTORE_ACTION = ACTN_ID
	FROM
		dbo.ActionType
		INNER JOIN dbo.Action ON ACTN_ID_TYPE = ACTT_ID
		INNER JOIN dbo.ActionPeriod ON AP_ID_AC = ACTN_ID
	WHERE ACTT_ID = 1 AND AP_ID_PERIOD = @PR_ID

	DECLARE @ACTION_PERIOD TABLE
		(
			APR_ID	SMALLINT
		)

	INSERT INTO @ACTION_PERIOD
		SELECT AP_ID_PERIOD
		FROM dbo.ActionPeriod
		WHERE AP_ID_AC = @RESTORE_ACTION


	DECLARE @distr TABLE
		(
			HST_ID	SMALLINT,
			DIS_NUM	INT,
			COMP	TINYINT,
			PERIOD	SMALLINT,
			CNT		TINYINT,
			TWICE	TINYINT
		)

	INSERT INTO @distr
		SELECT DISTINCT
			RPR_ID_HOST, RPR_DISTR, RPR_COMP, PR_ID, COUNT(*), 0
		FROM
			(
				SELECT
					RPR_ID_HOST, RPR_DISTR, RPR_COMP,
					(
						SELECT PR_ID
						FROM dbo.PeriodTable
						WHERE RPR_DATE >= PR_BREPORT AND RPR_DATE < DATEADD(DAY, 1, PR_EREPORT)
					) AS PR_ID
				FROM dbo.RegProtocol
				WHERE RPR_OPER = '���������'
			) AS o_O
		GROUP BY RPR_ID_HOST, RPR_DISTR, RPR_COMP, PR_ID

	IF @RESTORE_ACTION IS NULL
		UPDATE @distr
		SET TWICE = 1
		WHERE PERIOD = @PR_ID
	ELSE
		UPDATE z
		SET TWICE = 1
		FROM @distr z
		WHERE PERIOD = @PR_ID
			AND EXISTS
			(
				SELECT *
				FROM
					@distr a
					INNER JOIN dbo.ActionPeriod b ON b.AP_ID_PERIOD = a.PERIOD
				WHERE a.HST_ID = z.HST_ID
					AND a.DIS_NUM = z.DIS_NUM
					AND a.COMP = z.COMP
					AND a.PERIOD <> @PR_ID
			)

	DELETE FROM @distr WHERE PERIOD <> @PR_ID
	DELETE FROM @distr WHERE TWICE = 0

	INSERT INTO @TBL
		SELECT
			HST_ID, REG_ID_SYSTEM, DIS_NUM, COMP,
			REG_ID_TYPE, REG_ID_TECH_TYPE, REG_ID_HOST, REG_ID_NET,
			CNT
		FROM
			@distr	a
			INNER JOIN	dbo.SystemTable b ON a.HST_ID = b.SYS_ID_HOST
			INNER JOIN	dbo.PeriodRegTable c ON b.SYS_ID = c.REG_ID_SYSTEM
											AND DIS_NUM = REG_DISTR_NUM
											AND COMP = REG_COMP_NUM
		WHERE REG_ID_PERIOD = @PR_ID

	RETURN
END
GO
