USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Изменить данные о поле в таблице отчета
*/

CREATE PROCEDURE [dbo].[REPORT_FIELD_EDIT]
	@fieldid SMALLINT,
	@fieldname VARCHAR(50),
	@fieldcaption VARCHAR(100),
	@order INT
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE dbo.ReportFieldTable 
        SET RF_NAME = @fieldname, RF_CAPTION = @fieldcaption, RF_ORDER = @order 
    WHERE RF_ID = @fieldid                     
END


