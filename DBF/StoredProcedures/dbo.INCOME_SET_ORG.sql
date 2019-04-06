USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			
Дата создания:  	
Описание:		
*/
CREATE PROCEDURE [dbo].[INCOME_SET_ORG]
	@inid INT,
	@orgid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.IncomeTable
	SET IN_ID_ORG = @orgid
	WHERE IN_ID = @inid
END