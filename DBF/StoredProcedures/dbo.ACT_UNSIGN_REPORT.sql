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

CREATE PROCEDURE [dbo].[ACT_UNSIGN_REPORT]
	@actdate SMALLDATETIME
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
			CL_ID, CL_PSEDO, COUR_NAME, ACT_DATE, PR_DATE
		FROM 
			dbo.ClientCourView INNER JOIN
			dbo.ActPeriodView ON ACT_ID_CLIENT = CL_ID INNER JOIN
			dbo.PeriodTable ON PR_ID = ACT_ID_PERIOD
		WHERE ACT_SIGN IS NULL
			AND ACT_DATE <= @actdate
		ORDER BY COUR_NAME, CL_PSEDO, CL_ID, ACT_DATE
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
