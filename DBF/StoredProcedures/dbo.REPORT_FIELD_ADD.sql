USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Добавить данные о поле в отчете
*/

CREATE PROCEDURE [dbo].[REPORT_FIELD_ADD]
	@fieldname VARCHAR(50),
	@fieldcaption VARCHAR(100),
	@order INT
AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO dbo.ReportFieldTable(RF_NAME, RF_CAPTION, RF_ORDER) 
                          VALUES(@fieldname, @fieldcaption, @order)
END


