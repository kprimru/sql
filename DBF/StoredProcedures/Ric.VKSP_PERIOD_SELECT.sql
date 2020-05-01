USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[VKSP_PERIOD_SELECT]
	@PR_ALG	SMALLINT,
	@PR_ID	SMALLINT
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

		DECLARE @PR_DATE	SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ALG

		DECLARE @PR_START	SMALLINT
		DECLARE @PR_END		SMALLINT

		SET @PR_END		=	dbo.PeriodDelta(@PR_ID, 0)
		SET @PR_START	=	dbo.PeriodDelta(@PR_END, -12)

		DECLARE @SDATE	SMALLDATETIME
		DECLARE @EDATE	SMALLDATETIME

		DECLARE @VKSP_START	DECIMAL(10, 4)
		DECLARE @VKSP_END	DECIMAL(10, 4)

		IF @PR_DATE >= '20120601'
		BEGIN
			SELECT @SDATE = 
				(
					SELECT PR_DATE
					FROM dbo.PeriodTable
					WHERE PR_ID = @PR_START
				), 
				@VKSP_START =  Ric.VKSPGet(@PR_ALG, @PR_START, @PR_END, @PR_END),
				@EDATE = (
					SELECT PR_DATE
					FROM dbo.PeriodTable
					WHERE PR_ID = @PR_END
				), 
				@VKSP_END =  Ric.VKSPGet(@PR_ALG, @PR_END, @PR_END, @PR_END)
		END

		SELECT 
			@SDATE AS PR_START,	@VKSP_START AS VKSP_START,
			@EDATE AS PR_END,	@VKSP_END   AS VKSP_END
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Ric].[VKSP_PERIOD_SELECT] TO rl_ric_kbu;
GO