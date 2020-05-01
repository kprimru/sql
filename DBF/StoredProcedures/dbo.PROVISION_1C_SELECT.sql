USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PROVISION_1C_SELECT]
	@date	SMALLDATETIME,
	@org	INT
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
			CL_ID, CL_PSEDO, CL_INN,
			DATE, PAY_NUM, PRICE
		FROM 
			dbo.Provision a
			INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = b.CL_ID
		WHERE DATE = @DATE AND ID_ORG = @ORG
			AND PRICE > 0
		ORDER BY CL_PSEDO
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[PROVISION_1C_SELECT] TO rl_report_act_r;
GO