USE [DBF_NAH]
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

    UPDATE dbo.ReportTemplateTable
    SET RT_NAME = @reporttemplatename
    WHERE RT_ID = @reporttemplateid
END






GO
GRANT EXECUTE ON [dbo].[REPORT_TEMPLATE_RENAME] TO rl_report_w;
GO