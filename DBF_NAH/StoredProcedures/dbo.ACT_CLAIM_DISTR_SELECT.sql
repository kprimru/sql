USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_CLAIM_DISTR_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_CLAIM_DISTR_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_CLAIM_DISTR_SELECT]
	@RN		INTEGER,
	@DATA	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @ID UNIQUEIDENTIFIER

		SELECT @ID = ID
		FROM
			(
				SELECT ID, ROW_NUMBER() OVER(ORDER BY DATE) AS RN
				FROM [PC275-SQL\ALPHA].ClientDB.dbo.ActCalc
				WHERE STATUS = 1
			) AS o_O
		WHERE RN = @RN

		DECLARE @CLAIM TABLE
			(
				SYS_REG		VARCHAR(50),
				DISTR		INT,
				COMP		TINYINT,
				MON			SMALLDATETIME,
				CONFIRM		BIT
			)

		IF @RN IS NOT NULL
			INSERT INTO @CLAIM(SYS_REG, DISTR, COMP, MON, CONFIRM)
				SELECT
					SYS_REG, DISTR, COMP, MON,
					CASE
						WHEN a.CONFRM = 1 AND b.CONFIRM_DATE IS NULL THEN 0
						ELSE 1
					END
				FROM
					[PC275-SQL\ALPHA].ClientDB.dbo.ActCalcDetail a
					INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ActCalc b ON a.ID_MASTER = b.ID
				WHERE a.ID_MASTER = @ID
		ELSE
		BEGIN
			DECLARE @XML XML

			SET @XML = CAST(@DATA AS XML)

			INSERT INTO @CLAIM(SYS_REG, DISTR, COMP, MON, CONFIRM)
				SELECT
					c.value('s[1]', 'NVARCHAR(64)'),
					c.value('d[1]', 'INT'),
					c.value('c[1]', 'INT'),
					CONVERT(SMALLDATETIME, c.value('m[1]', 'NVARCHAR(64)'), 112),
					1
				FROM @XML.nodes('/act_claim/i') AS a(c)
		END

		SELECT
			CL_PSEDO, DIS_STR, CD_ID_DISTR, CD_ID_CLIENT, PR_DATE, PR_ID,
			BD_ID, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE, BD_UNPAY, CO_ID, CO_NUM, CO_END_DATE, DF_END,
			ACT_ERROR, CASE WHEN ISNULL(ACT_ERROR, '') <> 'Акт уже расчитан' THEN 1 ELSE 0 END AS CAC_CALC,
			CASE WHEN ISNULL(ACT_ERROR, '') <> 'Акт уже расчитан' THEN 1 ELSE 0 END AS CAN_CALC,
			DIS_NUM, SYS_REG_NAME, DIS_COMP_NUM
		FROM
			(
				SELECT
					CL_PSEDO, DIS_STR, CD_ID_DISTR, CD_ID_CLIENT, PR_DATE, PR_ID,
					BD_ID, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE, BD_UNPAY, CO_ID, CO_NUM, CO_END_DATE,
					SYS_REG_NAME, SYS_ORDER, DIS_NUM, DIS_COMP_NUM, DF_END,
					CASE
						WHEN
							EXISTS
								(
									SELECT *
									FROM dbo.ActAllIXView z WITH(NOEXPAND)
									WHERE a.SYS_REG_NAME = z.SYS_REG_NAME
										AND a.DIS_NUM = z.DIS_NUM
										AND a.DIS_COMP_NUM = z.DIS_COMP_NUM
										AND a.PR_DATE = z.PR_DATE
								) THEN 'Акт уже расчитан'
						WHEN
							NOT EXISTS
								(
									SELECT *
									FROM dbo.DistrDocumentView
									WHERE DIS_ID = CD_ID_DISTR AND DOC_PSEDO = 'ACT' AND DD_PRINT = 1
								) THEN 'В фин.установках запрет на формирование актов'
						WHEN
							(
								SELECT RN_SERVICE
								FROM dbo.RegNodeTable
								WHERE RN_DISTR_NUM = DIS_NUM
									AND RN_COMP_NUM = DIS_COMP_NUM
									AND RN_SYS_NAME = SYS_REG_NAME
							) <> 0 THEN 'Дистрибутив отключен от сопровождения'
						WHEN ISNULL(DF_END, dbo.DateOf(DATEADD(DAY, 1, GETDATE()))) < dbo.DateOf(GETDATE()) THEN 'Просрочены фин.установки'
						WHEN CONFIRM = 0 THEN 'Не подтверждена заявка'
						ELSE ''
					END AS ACT_ERROR
				FROM
					(
						SELECT
							DIS_STR, CD_ID_DISTR, CD_ID_CLIENT, CL_PSEDO, PR_DATE, PR_ID,
							BD_ID, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE, BD_UNPAY, CO_ID, CO_NUM, CO_END_DATE,
							c.SYS_ORDER, c.SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, DF_END, a.CONFIRM
						FROM
							--[PC275-SQL\ALPHA].ClientDB.dbo.ActCalcDetail a
							@CLAIM a
							/*
							INNER JOIN dbo.PeriodTable b ON PR_DATE = MON
							LEFT OUTER JOIN dbo.ClientDistrView c ON SYS_REG_NAME = SYS_REG AND DISTR = DIS_NUM AND DIS_COMP_NUM = COMP
							LEFT OUTER JOIN dbo.ClientTable ON CL_ID = CD_ID_CLIENT
							*/

							INNER JOIN dbo.PeriodTable b ON PR_DATE = MON
							INNER JOIN dbo.SystemTable d ON d.SYS_REG_NAME = a.SYS_REG
							INNER JOIN dbo.SystemTable e ON d.SYS_ID_HOST = e.SYS_ID_HOST
							INNER JOIN dbo.ClientDistrView c ON c.SYS_REG_NAME = e.SYS_REG_NAME AND DISTR = DIS_NUM AND DIS_COMP_NUM = COMP
							INNER JOIN dbo.ClientTable ON CL_ID = CD_ID_CLIENT

							CROSS APPLY
								(
									SELECT
										BD_ID, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE,
										(
											BD_TOTAL_PRICE -
												ISNULL((
													SELECT SUM(ID_PRICE)
													FROM
														dbo.IncomeDistrTable
														INNER JOIN dbo.IncomeTable ON IN_ID = ID_ID_INCOME
														INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR
													WHERE IN_ID_CLIENT = BL_ID_CLIENT
														AND ID_ID_PERIOD = PR_ID
														AND ID_ID_DISTR = c.CD_ID_DISTR
														AND SYS_ID_SO = 1
												), 0)
										) BD_UNPAY,
										(
											SELECT TOP 1 CO_ID
											FROM
												dbo.ContractDistrTable LEFT OUTER JOIN
												dbo.ContractTable ON CO_ID = COD_ID_CONTRACT AND CO_ID_CLIENT = CL_ID --AND CO_ACTIVE = 1
											WHERE COD_ID_DISTR = c.CD_ID_DISTR
											ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
										) AS CO_ID,
										(
											SELECT TOP 1 CO_NUM
											FROM
												dbo.ContractDistrTable LEFT OUTER JOIN
												dbo.ContractTable ON CO_ID = COD_ID_CONTRACT AND CO_ID_CLIENT = CL_ID --AND CO_ACTIVE = 1
											WHERE COD_ID_DISTR = c.CD_ID_DISTR
											ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
										) AS CO_NUM,
										(
											SELECT TOP 1 CO_END_DATE
											FROM
												dbo.ContractDistrTable LEFT OUTER JOIN
												dbo.ContractTable ON CO_ID = COD_ID_CONTRACT AND CO_ID_CLIENT = CL_ID --AND CO_ACTIVE = 1
											WHERE COD_ID_DISTR = c.CD_ID_DISTR
											ORDER BY CO_ACTIVE DESC, CO_END_DATE DESC
										) AS CO_END_DATE,
										(
											SELECT DF_END
											FROM
												dbo.DistrFinancingView
											WHERE DIS_ID = CD_ID_DISTR
										) AS DF_END
									FROM dbo.BillDistrView z
									WHERE BL_ID_CLIENT = CD_ID_CLIENT
										--AND DIS_ID = CD_ID_DISTR

										AND z.DIS_NUM = c.DIS_NUM
										AND z.DIS_COMP_NUM = c.DIS_COMP_NUM
										AND z.HST_ID = e.SYS_ID_HOST

										AND z.PR_ID = b.PR_ID
								) AS o_O
						--WHERE ID_MASTER = @ID
					) AS a
			) AS o_O
		ORDER BY CL_PSEDO, PR_DATE, SYS_ORDER, DIS_NUM, DIS_COMP_NUM, CO_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ACT_CLAIM_DISTR_SELECT] TO rl_act_w;
GO
