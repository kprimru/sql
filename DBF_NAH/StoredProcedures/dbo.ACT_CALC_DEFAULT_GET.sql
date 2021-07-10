USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[ACT_CALC_DEFAULT_GET]
	@clientid INT,
	@dt SMALLDATETIME = NULL
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

		SELECT SO_ID, SO_NAME, COUR_ID, COUR_NAME, PR_ID, PR_NAME
		FROM
			dbo.SaleObjectTable,
			dbo.ClientCourView,
			dbo.PeriodTable
		WHERE SO_ID = 1
			AND CL_ID = @clientid
			AND ISNULL(@dt, GETDATE()) BETWEEN PR_DATE AND PR_END_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ACT_CALC_DEFAULT_GET] TO rl_act_w;
GO