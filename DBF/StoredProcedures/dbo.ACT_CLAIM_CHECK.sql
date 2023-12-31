USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_CLAIM_CHECK]
	@RN		INTEGER,
	@DATA	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID UNIQUEIDENTIFIER

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

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
				MON			SMALLDATETIME
			)

		IF @RN IS NOT NULL
			INSERT INTO @CLAIM(SYS_REG, DISTR, COMP, MON)
				SELECT SYS_REG, DISTR, COMP, MON
				FROM [PC275-SQL\ALPHA].ClientDB.dbo.ActCalcDetail a
				WHERE ID_MASTER = @ID
		ELSE
		BEGIN
			DECLARE @XML XML

			SET @XML = CAST(@DATA AS XML)

			INSERT INTO @CLAIM(SYS_REG, DISTR, COMP, MON)
				SELECT
					c.value('s[1]', 'NVARCHAR(64)'),
					c.value('d[1]', 'INT'),
					c.value('c[1]', 'INT'),
					CONVERT(SMALLDATETIME, c.value('m[1]', 'NVARCHAR(64)'), 112)
				FROM @XML.nodes('/act_claim/i') AS a(c)
		END


		DECLARE @ERR_TEXT NVARCHAR(MAX)

		SELECT @ERR_TEXT =
			(
				SELECT ERR_TXT + CHAR(10)
				FROM
					(
						SELECT
							CASE
								WHEN NOT EXISTS
									(
										SELECT *
										FROM dbo.ClientDistrView c
										WHERE SYS_REG_NAME = SYS_REG AND DISTR = DIS_NUM AND DIS_COMP_NUM = COMP
									) THEN '����������� ����������� � ������� (' + ISNULL(DIS_STR, SYS_REG_NAME + CONVERT(NVARCHAR(32), DIS_NUM)) + ')'
								WHEN NOT EXISTS
									(
										SELECT *
										FROM dbo.BillDistrView z
										WHERE BL_ID_CLIENT = CD_ID_CLIENT
											AND DIS_ID = CD_ID_DISTR
											AND z.PR_ID = b.PR_ID
									) THEN '����������� ���� ������. � ������� (' + CL_PSEDO + ') �� (' + CONVERT(NVARCHAR(32), PR_DATE, 104) + ') (' + DIS_STR + ')'
							END AS ERR_TXT
						FROM
							--[PC275-SQL\ALPHA].ClientDB.dbo.ActCalcDetail a
							@CLAIM a
							INNER JOIN dbo.PeriodTable b ON PR_DATE = MON
							LEFT OUTER JOIN dbo.ClientDistrView c ON SYS_REG_NAME = SYS_REG AND DISTR = DIS_NUM AND DIS_COMP_NUM = COMP
							LEFT OUTER JOIN dbo.ClientTable ON CL_ID = CD_ID_CLIENT
						--WHERE ID_MASTER = @ID
					) AS o_O
				WHERE ERR_TXT IS NOT NULL
				FOR XML PATH('')
			)

		IF ISNULL(REPLACE(@ERR_TEXT, CHAR(10), N''), N'') = N''
			SELECT '' AS ERR_TXT
			WHERE 1 = 0
		ELSE
			SELECT @ERR_TEXT AS ERR_TXT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_CLAIM_CHECK] TO rl_act_w;
GO
