USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.10.2008
Описание:	  Удалить отчет с указанным кодом.
*/

ALTER PROCEDURE [dbo].[REPORT_TEMPLATE_DELETE]
	@reporttemplateid INT
AS
BEGIN
	SET NOCOUNT ON;

    DELETE FROM dbo.ReportTemplateTable
    WHERE RT_ID = @reporttemplateid
END






GO
GRANT EXECUTE ON [dbo].[REPORT_TEMPLATE_DELETE] TO rl_report_w;
GO