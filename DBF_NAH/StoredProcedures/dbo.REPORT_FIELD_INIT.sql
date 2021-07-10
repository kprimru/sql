USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Очистить таблицу полей отчета
*/

ALTER PROCEDURE [dbo].[REPORT_FIELD_INIT]
AS
BEGIN
	SET NOCOUNT ON;

    DELETE FROM dbo.ReportFieldTable

    DBCC CHECKIDENT(ReportFieldTable, RESEED, 0)
END




GO
