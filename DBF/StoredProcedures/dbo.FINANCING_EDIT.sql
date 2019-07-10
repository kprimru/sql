USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Изменить данные о типе 
               финансирования с указанным кодом
*/

CREATE PROCEDURE [dbo].[FINANCING_EDIT] 
	@financingid SMALLINT,
	@financingname VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.FinancingTable 
	SET FIN_NAME = @financingname,
		FIN_ACTIVE = @active
	WHERE FIN_ID = @financingid

	SET NOCOUNT OFF
END