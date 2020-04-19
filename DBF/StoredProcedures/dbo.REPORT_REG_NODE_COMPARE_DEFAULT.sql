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
CREATE PROCEDURE [dbo].[REPORT_REG_NODE_COMPARE_DEFAULT]	
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

		DECLARE @DPR_ID SMALLINT
		DECLARE @SPR_ID SMALLINT
			
		SELECT @DPR_ID = MAX(REG_ID_PERIOD) 
		FROM dbo.PeriodRegTable
		
		SELECT @SPR_ID = dbo.PERIOD_PREV(@DPR_ID)
		
		SELECT a.PR_NAME AS SPR_NAME, a.PR_ID AS SPR_ID, b.PR_NAME AS DPR_NAME, b.PR_ID AS DPR_ID
		FROM
			dbo.PeriodTable a,
			dbo.PeriodTable b
		WHERE a.PR_ID = @SPR_ID AND b.PR_ID = @DPR_ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
