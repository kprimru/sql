USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:	17.06.09
Описание:		удалить несколько записей
				из таблицы накладных
*/

CREATE PROCEDURE [dbo].[CONSIGNMENT_DETAILS_DELETE]
	@rowlist VARCHAR(200)
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

		IF OBJECT_ID('tempdb..#dbf_consrow') IS NOT NULL
			DROP TABLE #dbf_consrow

		CREATE TABLE #dbf_consrow
			(
			ROW_ID INT NOT NULL
			)

		IF @rowlist IS NOT NULL
			BEGIN
			--парсить строчку и выбирать нужные значения
			INSERT INTO #dbf_consrow
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@rowlist, ',')
			END


		DELETE
		FROM 
			dbo.ConsignmentDetailTable
		WHERE CSD_ID IN (SELECT ROW_ID FROM #dbf_consrow)

		IF OBJECT_ID('tempdb..#dbf_consrow') IS NOT NULL
			DROP TABLE #dbf_consrow

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
