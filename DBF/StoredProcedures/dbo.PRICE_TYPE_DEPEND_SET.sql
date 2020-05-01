USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_TYPE_DEPEND_SET]
	@PT_ID		SMALLINT,
	@DEPEND		SMALLINT,
	@COEF		DECIMAL(6, 2),
	@PR_LIST	VARCHAR(MAX),
	@PR_BEGIN	SMALLINT,
	@PR_END		SMALLINT,
	@PR_ID		SMALLINT,
	@PR_NEXT	BIT
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

		DECLARE @PERIOD	TABLE(PR_ID SMALLINT)

		IF @PR_LIST IS NOT NULL
		BEGIN
			INSERT INTO @PERIOD(PR_ID)
				SELECT Item
				FROM dbo.GET_TABLE_FROM_LIST(@PR_LIST, ',')
		END
		ELSE IF @PR_ID IS NOT NULL
		BEGIN
			IF @PR_NEXT = 1
				INSERT INTO @PERIOD(PR_ID)
					SELECT PR_ID
					FROM dbo.PeriodTable
					WHERE PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_ID)
			ELSE
				INSERT INTO @PERIOD(PR_ID)
					SELECT @PR_ID
		END
		ELSE IF @PR_BEGIN IS NOT NULL AND @PR_END IS NOT NULL
		BEGIN
			INSERT INTO @PERIOD
				SELECT PR_ID
				FROM dbo.PeriodTable
				WHERE PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_BEGIN)
					AND PR_DATE <= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_END)
		END

		UPDATE dbo.PriceDepend
		SET PD_COEF = @COEF,
			PD_ID_SOURCE = @DEPEND
		WHERE PD_ID_TYPE = @PT_ID
			AND PD_ID_PERIOD IN (SELECT PR_ID FROM @PERIOD)

		INSERT INTO dbo.PriceDepend(PD_ID_TYPE, PD_ID_SOURCE, PD_ID_PERIOD, PD_COEF)
			SELECT @PT_ID, @DEPEND, PR_ID, @COEF
			FROM @PERIOD
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.PriceDepend
					WHERE PD_ID_TYPE = @PT_ID
						AND PD_ID_PERIOD = PR_ID
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[PRICE_TYPE_DEPEND_SET] TO rl_price_type_w;
GO