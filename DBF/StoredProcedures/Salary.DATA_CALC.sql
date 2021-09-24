USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[DATA_CALC]
	@CONTROL	NVARCHAR(128),
	@KGS		DECIMAL(8, 4),
	@TO_ID		INT,
	@PR_ID		SMALLINT,
	@TYPE		SMALLINT,
	@TO_COUNT	INT,
	@TO_TOTAL	MONEY,
	@SYS_COUNT	INT,
	@COEF		DECIMAL(8, 4),
	@MIN		MONEY,
	@MAX		MONEY,
	@PAY		BIT,
	@UPDATES	BIT,
	@ACT		BIT,
	@INET		BIT,
	@SUM		MONEY,
	@PERCENT	DECIMAL(8, 4),
	@TOTAL		MONEY,
	@HANDS		MONEY,
	@NOTE		NVARCHAR(MAX)
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

		IF @CONTROL = 'ClientRefDBEditEh'
		BEGIN
			SET @TO_ID		=	NULL
			SET @TYPE		=	NULL
			SET @TO_COUNT	=	NULL
			SET @TO_TOTAL	=	NULL
			SET @SYS_COUNT	=	NULL
			SET @COEF		=	NULL
			SET @MIN		=	NULL
			SET @MAX		=	NULL
			SET @PAY		=	NULL
			SET @ACT		=	NULL
			SET @SUM		=	NULL
			SET @PERCENT	=	NULL
			SET @TOTAL		=	NULL
		END
		ELSE IF @CONTROL = 'TORefDBEditEh'
		BEGIN
			SET @TO_TOTAL	=	NULL
			SET @SYS_COUNT	=	NULL
			SET @COEF		=	NULL
			SET @MIN		=	NULL
			SET @MAX		=	NULL
			SET @PAY		=	NULL
			SET @ACT		=	NULL
			SET @SUM		=	NULL
			SET @PERCENT	=	NULL
			SET @TOTAL		=	NULL
		END
		ELSE IF @CONTROL = 'CityRefDBEditEh'
		BEGIN
			SET @COEF = @COEF
		END
		ELSE IF @CONTROL = 'TOCountDBNumberEditEh'
		BEGIN
			SET @PAY		=	NULL
			SET @ACT		=	NULL
			SET @SUM		=	NULL
			SET @TOTAL		=	NULL
		END
		ELSE IF @CONTROL = 'TotalPriceDBNumberEditEh'
		BEGIN
			SET @MIN		=	NULL
			SET @MAX		=	NULL
			SET @PAY		=	NULL
			SET @ACT		=	NULL
			SET @SUM		=	NULL
			SET @TOTAL		=	NULL
		END
		ELSE IF @CONTROL = 'PeriodRefDBEditEh'
		BEGIN
			SET @MIN		=	NULL
			SET @MAX		=	NULL
			SET @PAY		=	NULL
			SET @ACT		=	NULL
			SET @SUM		=	NULL
			SET @TOTAL		=	NULL
		END
		ELSE IF @CONTROL = 'TypeRefDBEditEh'
		BEGIN
			SET @TO_TOTAL	=	NULL
			SET @SYS_COUNT	=	NULL
			SET @COEF		=	NULL
			SET @MIN		=	NULL
			SET @MAX		=	NULL
			SET @PAY		=	NULL
			SET @ACT		=	NULL
			SET @SUM		=	NULL
			SET @PERCENT	=	NULL
			SET @TOTAL		=	NULL
		END
		ELSE IF @CONTROL = 'SysCountDBNumberEditEh'
		BEGIN
			SET @COEF		=	NULL
			SET @MIN		=	NULL
			SET @MAX		=	NULL
			SET @PAY		=	NULL
			SET @ACT		=	NULL
			SET @SUM		=	NULL
			SET @TOTAL		=	NULL
		END
		ELSE IF @CONTROL = 'MinDBNumberEditEh'
		BEGIN
			SET @MIN		=	NULL
			SET @TOTAL		=	NULL
		END
		ELSE IF @CONTROL = 'MaxDBNumberEditEh'
		BEGIN
			SET @MAX		=	NULL
			SET @TOTAL		=	NULL
		END
		ELSE IF @CONTROL = 'PercentDBNumberEditEh'
		BEGIN
			SET @PERCENT	=	NULL
			SET @TOTAL		=	NULL
		END

		/*
		ClientRefDBEditEh
		TORefDBEditEh
		CityRefDBEditEh
		TOCountDBNumberEditEh
		TotalPriceDBNumberEditEh
		PeriodRefDBEditEh
		TypeRefDBEditEh
		SysCountDBNumberEditEh
		MinDBNumberEditEh
		MaxDBNumberEditEh
		CoefDBNumberEditEh
		PercentDBNumberEditEh
		PriceDBNumberEditEh
		TotalDBNumberEditEh
		HandsDBNumberEditEh
		PayDBCheckBoxEh
		UpdatesDBCheckBoxEh
		ActDBCheckBoxEh
		InetDBCheckBoxEh
		*/

		IF @TYPE IS NULL
			SELECT @TYPE = CL_ID_TYPE
			FROM
				dbo.ClientTable
				INNER JOIN dbo.ToTable ON TO_ID_CLIENT = CL_ID
			WHERE TO_ID = @TO_ID

		IF @TO_COUNT IS NULL
			SELECT @TO_COUNT = COUNT(DISTINCT b.REG_NUM_CLIENT)
			FROM
				dbo.ToTable a
				INNER JOIN dbo.ToTable d ON a.TO_ID_CLIENT = d.TO_ID_CLIENT
				INNER JOIN dbo.PeriodRegTable b ON d.TO_NUM = b.REG_NUM_CLIENT
				INNER JOIN dbo.DistrStatusTable c ON c.DS_ID = b.REG_ID_STATUS
			WHERE b.REG_ID_PERIOD = @PR_ID AND c.DS_REG = 0 AND a.TO_ID = @TO_ID

		IF @TO_TOTAL IS NULL
			SELECT @TO_TOTAL = SUM(AD_TOTAL_PRICE)
			FROM
				dbo.ActIXView WITH(NOEXPAND)
				INNER JOIN dbo.ToTable ON TO_ID_CLIENT = ACT_ID_CLIENT
			WHERE AD_ID_PERIOD = @PR_ID AND TO_ID = @TO_ID

		IF @SYS_COUNT IS NULL
			SELECT @SYS_COUNT = COUNT(*)
			FROM
				dbo.ToTable a
				INNER JOIN dbo.PeriodRegTable b ON a.TO_NUM = b.REG_NUM_CLIENT
				INNER JOIN dbo.DistrStatusTable c ON c.DS_ID = b.REG_ID_STATUS
			WHERE b.REG_ID_PERIOD = @PR_ID AND c.DS_REG = 0 AND a.TO_ID = @TO_ID

		IF @COEF IS NULL
			SELECT @COEF = PC_VALUE
			FROM dbo.PayCoefTable
			WHERE @SYS_COUNT BETWEEN PC_START AND PC_END

		IF @INET IS NULL
			SET @INET = 0

		IF @ACT IS NULL
			SET @ACT =
				CASE
					WHEN EXISTS
						(
							SELECT *
							FROM
								dbo.ActIXView WITH(NOEXPAND)
								INNER JOIN dbo.TODistrTable ON TD_ID_DISTR = AD_ID_DISTR
								INNER JOIN dbo.TOTable ON TO_ID = TD_ID_TO AND TO_ID_CLIENT = ACT_ID_CLIENT
							WHERE AD_ID_PERIOD = @PR_ID AND TO_ID = @TO_ID
						) THEN 1
					ELSE 0
				END

		IF @PAY IS NULL
			SET @PAY =
				CASE
					WHEN EXISTS
						(
							SELECT *
							FROM
								dbo.TOTable t INNER JOIN
								dbo.TODistrTable ON TD_ID_TO = TO_ID INNER JOIN
								dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR INNER JOIN
								dbo.BillRestView ON BD_ID_DISTR = DIS_ID AND BL_ID_CLIENT = TO_ID_CLIENT
							WHERE t.TO_ID = @TO_ID
								AND BL_ID_PERIOD = @PR_ID
								AND BD_REST > 0
						) THEN 0
					ELSE 1
				END

		/*
		IF @PERCENT IS NULL



		@MIN		MONEY,
		@MAX		MONEY,
		@SUM		MONEY,
		@PERCENT	DECIMAL(8, 4),
		@TOTAL		MONEY,
		@HANDS		MONEY,
		*/

		SELECT
			@TYPE AS TYPE,
			(SELECT CLT_NAME FROM dbo.ClientTypeTable WHERE CLT_ID = @TYPE) AS TP_NAME,
			@TO_COUNT AS TO_COUNT,
			@TO_TOTAL AS TO_PRICE,
			@SYS_COUNT AS SYS_COUNT,
			@COEF AS COEF,
			@MIN AS MIN_VALUE,
			@MAX AS MAX_VALUE,
			@PAY AS PAY,
			@UPDATES AS UPDATES,
			@ACT AS ACT,
			@INET AS INET,
			@SUM AS PRICE,
			@PERCENT AS PRCNT,
			@TOTAL AS TOTAL,
			@HANDS AS HANDS,
			@NOTE AS NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[DATA_CALC] TO rl_courier_pay;
GO
