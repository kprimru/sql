﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.10.2008
Описание:	  Переименовать отчет. Указать
               новое название отчету с
               указанным кодом
*/

ALTER PROCEDURE [dbo].[REPORT_TEMPLATE_RENAME]
	@reporttemplateid INT,
	@reporttemplatename VARCHAR(150)
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

		UPDATE dbo.ReportTemplateTable
		SET RT_NAME = @reporttemplatename
		WHERE RT_ID = @reporttemplateid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REPORT_TEMPLATE_RENAME] TO rl_report_w;
GO
