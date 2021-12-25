USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			коллектив авторов
Дата креации:	19.02.2009
Описуха:			Сбрасывает регузел (RegNodeFullTable)
				в историю регузла (PeriodRegtable) и
				в новые системы (PeriodRegNewTable)
*/
ALTER PROCEDURE [dbo].[REG_NODE_MOVE]
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @prdate SMALLDATETIME

		SELECT @prdate = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @periodid

		IF EXISTS
			(
				SELECT *
				FROM dbo.PeriodRegTable
				WHERE REG_ID_PERIOD = @periodid
			)
			DELETE FROM dbo.PeriodRegTable
			WHERE REG_ID_PERIOD = @periodid

		IF EXISTS
			(
				SELECT *
				FROM dbo.PeriodRegNewTable
				WHERE RNN_ID_PERIOD = @periodid
			)
			DELETE FROM dbo.PeriodRegNewTable
			WHERE RNN_ID_PERIOD = @periodid

		INSERT INTO	dbo.PeriodRegTable (
					REG_ID_PERIOD, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
					REG_ID_HOST, REG_ID_TYPE, REG_ID_NET, REG_ID_STATUS,
					REG_ID_TECH_TYPE, REG_DATE, REG_FIRST, REG_COMMENT, REG_COMPLECT,
					REG_NUM_CLIENT, REG_PSEDO_CLIENT, REG_ID_COUR, REG_MAIN, REG_OFFLINE
					)
			SELECT	@periodid, RN_ID_SYSTEM, RN_DISTR_NUM, RN_COMP_NUM, RN_ID_SUBHOST,
					RN_ID_TYPE, RN_ID_NET, RN_ID_STATUS, RN_ID_TECH_TYPE,
					RN_REG_DATE, RN_FIRST_REG, RN_COMMENT, RN_COMPLECT,
					TO_NUM, CL_PSEDO, TO_ID_COUR, RN_MAIN, RN_OFFLINE
			FROM
				dbo.RegNodeFullTable LEFT OUTER JOIN
				(
					SELECT SYS_ID, DIS_NUM, DIS_COMP_NUM, TO_NUM, TO_ID_COUR, CL_PSEDO
					FROM
						dbo.ClientTable INNER JOIN
						dbo.TOTable ON TO_ID_CLIENT = CL_ID INNER JOIN
						dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
						dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR
				) AS t ON RN_ID_SYSTEM = SYS_ID
					AND RN_DISTR_NUM = DIS_NUM
					AND RN_COMP_NUM = DIS_COMP_NUM


		INSERT INTO dbo.PeriodRegNewTable (
					RNN_ID_PERIOD, RNN_ID_SYSTEM, RNN_DISTR_NUM, RNN_COMP_NUM, RNN_ID_HOST,
					RNN_ID_TYPE, RNN_ID_NET, RNN_ID_TECH_TYPE, RNN_DATE, RNN_COMMENT,
					RNN_DATE_ON, RNN_NUM_CLIENT, RNN_PSEDO_CLIENT
					)
			SELECT	@periodid, RN_ID_SYSTEM, RN_DISTR_NUM, RN_COMP_NUM, RN_ID_SUBHOST,
					RN_ID_TYPE, RN_ID_NET, RN_ID_TECH_TYPE, RN_REG_DATE, RN_COMMENT,
					@prdate, TO_NUM, CL_PSEDO
			FROM
				dbo.RegNodeFullTable a LEFT OUTER JOIN
				(
					SELECT SYS_ID, DIS_NUM, DIS_COMP_NUM, TO_NUM, TO_ID_COUR, CL_PSEDO
					FROM
						dbo.ClientTable INNER JOIN
						dbo.TOTable ON TO_ID_CLIENT = CL_ID INNER JOIN
						dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
						dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR
				) AS t ON RN_ID_SYSTEM = SYS_ID
					AND RN_DISTR_NUM = DIS_NUM
					AND RN_COMP_NUM = DIS_COMP_NUM
			WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.PeriodRegNewTable b
						WHERE
							(
								SELECT SYS_ID_HOST
								FROM dbo.SystemTable
								WHERE SYS_ID = a.RN_ID_SYSTEM
							) =
							(
								SELECT SYS_ID_HOST
								FROM dbo.SystemTable
								WHERE SYS_ID = b.RNN_ID_SYSTEM
							)
							AND a.RN_DISTR_NUM = b.RNN_DISTR_NUM
							AND a.RN_COMP_NUM  = b.RNN_COMP_NUM
					) AND RN_ID_STATUS = 1

		UPDATE dbo.ClientDistrTable
		SET CD_REG_DATE = RNN_DATE
		FROM
			dbo.ClientDistrTable INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
			dbo.PeriodRegNewTable ON RNN_ID_SYSTEM = SYS_ID AND
								RNN_DISTR_NUM = DIS_NUM AND
								RNN_COMP_NUM = DIS_COMP_NUM
		WHERE CD_REG_DATE IS NULL

		UPDATE A
		SET RNN_ID_PERIOD = C.REG_ID_PERIOD
		FROM dbo.PeriodRegNewTable A
		INNER JOIN dbo.SystemTable B ON a.RNN_ID_SYSTEM = b.SYS_ID
		INNER JOIN dbo.PeriodRegNewDistrView C ON c.SYS_ID_HOST = b.SYS_ID_HOST AND c.REG_DISTR_NUM = a.RNN_DISTR_NUM AND c.REG_COMP_NUM = a.RNN_COMP_NUM
		INNER JOIN dbo.PeriodTable D ON a.RNN_ID_PERIOD = D.PR_ID
		WHERE a.RNN_ID_PERIOD != C.REG_ID_PERIOD
			AND D.PR_DATE >= '20180401'

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REG_NODE_MOVE] TO rl_reg_node_history_w;
GO
