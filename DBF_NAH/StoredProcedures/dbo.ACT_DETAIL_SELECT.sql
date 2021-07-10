USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/

ALTER PROCEDURE [dbo].[ACT_DETAIL_SELECT]
	@actid INT
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

		SELECT
				AD_ID, DIS_ID, DIS_STR, TX_ID, TX_NAME, TX_PERCENT,
				AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE, --AD_DATE
				PR_DATE
		FROM
			dbo.ActDistrView
		WHERE ACT_ID = @actid
		ORDER BY DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END














GO
GRANT EXECUTE ON [dbo].[ACT_DETAIL_SELECT] TO rl_act_r;
GO