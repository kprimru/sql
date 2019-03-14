USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Удалить поле из таблицы данных об отчете
*/

CREATE PROCEDURE [dbo].[REPORT_FIELD_DELETE]
	@fieldid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

    DELETE FROM dbo.ReportFieldTable         
    WHERE RF_ID = @fieldid                     
END


