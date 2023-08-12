USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DBF_CACHE_COMPARE_AND_SYNC]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DBF_CACHE_COMPARE_AND_SYNC]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[DBF_CACHE_COMPARE_AND_SYNC]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Distr Table
    (
        SYS_REG_NAME    VarChar(50)     NOT NULL,
        DIS_NUM         Int             NOT NULL,
        DIS_COMP_NUM    TinyInt         NOT NULL,
        UPD_DATE        DateTime        NOT NULL,
        PRIMARY KEY CLUSTERED(DIS_NUM, SYS_REG_NAME, DIS_COMP_NUM)
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Distr(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, UPD_DATE)
		SELECT D.[SystemReg], D.[Distr], D.[Comp], GetDate()
		FROM
		(
			SELECT
				[SystemReg] = IsNull(C.[SYS_REG_NAME], D.[SYS_REG_NAME]),
				[Distr]		= IsNull(C.[DIS_NUM], D.[DIS_NUM]),
				[Comp]		= IsNull(C.[DIS_COMP_NUM], D.[DIS_COMP_NUM])
			FROM dbo.DBFAct AS C
			FULL JOIN
			(
				SELECT D.SYS_REG_NAME, D.DIS_NUM, D.DIS_COMP_NUM, D.PR_DATE, Sum(D.AD_TOTAL_PRICE) AS AD_TOTAL_PRICE, Max(D.ID_CNT) AS ID_CNT
				FROM [DBF].[dbo.ActAllIXView] AS D WITH(NOEXPAND)
				GROUP BY D.SYS_REG_NAME, D.DIS_NUM, D.DIS_COMP_NUM, D.PR_DATE
			) AS D ON D.SYS_REG_NAME = C.SYS_REG_NAME AND D.DIS_NUM = C.DIS_NUM AND D.DIS_COMP_NUM = C.DIS_COMP_NUM AND D.PR_DATE = C.PR_DATE AND D.AD_TOTAL_PRICE = C.AD_TOTAL_PRICE
			WHERE C.ID IS NULL OR D.ID_CNT IS NULL
			---
			UNION
			---
			SELECT
				[SystemReg] = IsNull(C.[SYS_REG_NAME], D.[SYS_REG_NAME]),
				[Distr]		= IsNull(C.[DIS_NUM], D.[DIS_NUM]),
				[Comp]		= IsNull(C.[DIS_COMP_NUM], D.[DIS_COMP_NUM])
			FROM dbo.DBFBill AS C
			FULL JOIN [DBF].[dbo.BillAllIXView] AS D WITH(NOEXPAND) ON D.SYS_REG_NAME = C.SYS_REG_NAME AND D.DIS_NUM = C.DIS_NUM AND D.DIS_COMP_NUM = C.DIS_COMP_NUM AND D.PR_DATE = C.PR_DATE AND D.BD_TOTAL_PRICE = C.BD_TOTAL_PRICE
			WHERE C.ID IS NULL OR D.CNT IS NULL
			---
			UNION
			---
			SELECT
				[SystemReg] = IsNull(C.[SYS_REG_NAME], D.[SYS_REG_NAME]),
				[Distr]		= IsNull(C.[DIS_NUM], D.[DIS_NUM]),
				[Comp]		= IsNull(C.[DIS_COMP_NUM], D.[DIS_COMP_NUM])
			FROM dbo.DBFIncome AS C
			FULL JOIN [DBF].[dbo.IncomeAllIXView] AS D WITH(NOEXPAND) ON D.SYS_REG_NAME = C.SYS_REG_NAME AND D.DIS_NUM = C.DIS_NUM AND D.DIS_COMP_NUM = C.DIS_COMP_NUM AND D.PR_DATE = C.PR_DATE AND D.ID_PRICE = C.ID_PRICE
			WHERE C.ID IS NULL OR D.ID_CNT IS NULL
			---
			UNION
			---
			SELECT
				[SystemReg] = IsNull(C.[SYS_REG_NAME], D.[SYS_REG_NAME]),
				[Distr]		= IsNull(C.[DIS_NUM], D.[DIS_NUM]),
				[Comp]		= IsNull(C.[DIS_COMP_NUM], D.[DIS_COMP_NUM])
			FROM dbo.DBFIncomeDate AS C
			FULL JOIN [DBF].[dbo.IncomeDateIXView] AS D WITH(NOEXPAND) ON D.SYS_REG_NAME = C.SYS_REG_NAME AND D.DIS_NUM = C.DIS_NUM AND D.DIS_COMP_NUM = C.DIS_COMP_NUM AND D.PR_DATE = C.PR_DATE AND D.IN_DATE = C.IN_DATE
			WHERE C.ID IS NULL OR D.ID_CNT IS NULL
			---
			UNION
			---
			SELECT
				[SystemReg] = IsNull(C.[SYS_REG_NAME], D.[SYS_REG_NAME]),
				[Distr]		= IsNull(C.[DIS_NUM], D.[DIS_NUM]),
				[Comp]		= IsNull(C.[DIS_COMP_NUM], D.[DIS_COMP_NUM])
			FROM dbo.DBFBillRest AS C
			FULL JOIN [DBF].[dbo.BillAllRestView] AS D ON D.SYS_REG_NAME = C.SYS_REG_NAME AND D.DIS_NUM = C.DIS_NUM AND D.DIS_COMP_NUM = C.DIS_COMP_NUM AND D.PR_DATE = C.PR_DATE AND D.BD_REST = C.BD_REST
			WHERE C.ID IS NULL OR D.BD_REST IS NULL
		) AS D;

		SET @Params =
            (
                SELECT
                    [Name] = 'DISTRS',
                    [Value] =
                        (
                            SELECT
                                SYS_REG_NAME,
                                DIS_NUM,
                                DIS_COMP_NUM
                            FROM @Distr
                            FOR XML RAW('DISTR')
                        )
                FOR XML RAW('PARAM'), ROOT('PARAMS')
            );

        EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'Получили список дистрибутивов для синхронизации',
            @Params         = @Params;

		INSERT INTO [DBF].[Sync.DistrFinancing](SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, UPD_DATE)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, UPD_DATE
		FROM @Distr;

		EXEC [dbo].[DBF_CACHE_SYNC_INTERNAL];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
