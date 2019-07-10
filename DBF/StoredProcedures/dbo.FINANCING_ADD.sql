USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Добавить тип финансирования в справочник
*/

CREATE PROCEDURE [dbo].[FINANCING_ADD] 
	@financingname VARCHAR(100),
	@active BIT = 1,
	@oldcode INT = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.FinancingTable (FIN_NAME, FIN_ACTIVE, FIN_OLD_CODE) 
	VALUES (@financingname, @active, @oldcode)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END