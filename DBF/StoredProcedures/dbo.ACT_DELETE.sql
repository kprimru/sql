USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:		
*/

CREATE PROCEDURE [dbo].[ACT_DELETE]
	@actid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CLIENT	INT
	DECLARE @TXT	VARCHAR(MAX)
	
	EXEC dbo.ACT_PROTOCOL @actid, @CLIENT OUTPUT, @TXT OUTPUT	

	EXEC dbo.FINANCING_PROTOCOL_ADD 'ACT', 'Удаление акта', @TXT, @CLIENT, @actid

	DELETE 
	FROM dbo.SaldoTable
	WHERE SL_ID_ACT_DIS IN 
			(
				SELECT AD_ID 
				FROM dbo.ActDistrTable 
				WHERE AD_ID_ACT = @actid
			)

	DELETE 
	FROM dbo.ActDistrTable
	WHERE AD_ID_ACT = @actid

	DELETE 
	FROM dbo.ActTable
	WHERE ACT_ID = @actid
END


