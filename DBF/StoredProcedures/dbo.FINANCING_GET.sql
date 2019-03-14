USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[FINANCING_GET] 
	@financingid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT FIN_ID, FIN_NAME, FIN_ACTIVE
	FROM dbo.FinancingTable 
	WHERE FIN_ID = @financingid 

	SET NOCOUNT OFF
END



