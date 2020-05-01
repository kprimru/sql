USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

ALTER PROCEDURE [dbo].[SYSTEM_WEIGHT_GET] 
	@swid INT = NULL
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

		SELECT SW_ID, SYS_SHORT_NAME, SYS_ID, PR_DATE, PR_ID, SW_WEIGHT, SW_PROBLEM, SW_ACTIVE
		FROM 
			dbo.SystemWeightTable a INNER JOIN
			dbo.SystemTable b ON a.SW_ID_SYSTEM = b.SYS_ID INNER JOIN
			dbo.PeriodTable c ON c.PR_ID = a.SW_ID_PERIOD
		WHERE SW_ID = @swid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SYSTEM_WEIGHT_GET] TO rl_system_weight_r;
GO