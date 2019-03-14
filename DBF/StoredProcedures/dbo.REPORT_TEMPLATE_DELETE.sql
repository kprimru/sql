USE [DBF]
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

CREATE PROCEDURE [dbo].[REPORT_TEMPLATE_DELETE]
	@reporttemplateid INT
AS
BEGIN
	SET NOCOUNT ON;
    
    DELETE FROM dbo.ReportTemplateTable 
    WHERE RT_ID = @reporttemplateid
END





