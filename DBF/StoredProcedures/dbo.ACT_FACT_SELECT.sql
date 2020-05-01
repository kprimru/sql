USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		все акты, автомотически сгенерированные
				за раз
*/
ALTER PROCEDURE [dbo].[ACT_FACT_SELECT]
	@date VARCHAR(100)
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
	
		DECLARE @d DATETIME
		SET @d = CONVERT(DATETIME, @date, 121)

		SELECT * 
		FROM dbo.ActFactMasterTable 
		WHERE AFM_DATE = @d
		ORDER BY CL_PSEDO, CL_ID, CO_NUM

		SELECT * 
		FROM dbo.ActFactDetailTable 
		WHERE AFD_ID_AFM IN (SELECT AFM_ID FROM dbo.ActFactMasterTable WHERE AFM_DATE = @d)
		ORDER BY AFD_ID_AFM, TO_NUM, SYS_ORDER	
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[ACT_FACT_SELECT] TO rl_act_p;
GO