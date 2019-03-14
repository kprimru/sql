USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает ID типа финансирования 
                с указанным названием. 
*/

CREATE PROCEDURE [dbo].[FINANCING_CHECK_NAME] 
	@financingname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT FIN_ID
	FROM dbo.FinancingTable
	WHERE FIN_NAME = @financingname

	SET NOCOUNT OFF
END




