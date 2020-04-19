USE [DBF]
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

CREATE PROCEDURE [dbo].[REPORT_INCOME]
	@date SMALLDATETIME,
	@orgid SMALLINT
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
			CL_ID, CL_PSEDO, CL_FULL_NAME, IN_DATE, IN_PAY_DATE, IN_PAY_NUM, 
			ID_PRICE, DIS_STR, DIS_ID, SYS_ORDER
		FROM 
			dbo.IncomeTable INNER JOIN
			dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID INNER JOIN
			dbo.ClientTable ON CL_ID = IN_ID_CLIENT INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = ID_ID_DISTR
		WHERE IN_DATE = @date AND IN_ID_ORG = @orgid
		ORDER BY CL_PSEDO, CL_ID, IN_ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
