USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RISK_REPORT_NOTIFY]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[RISK_REPORT_NOTIFY]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[RISK_REPORT_NOTIFY]
	@Report_Id	Integer
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

		/*
		Сравниваем текущий и предыдущий отчет и между ними смотрим насколько изменились показатели
		По критичным изменениям шлем уведомляшки
		*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
