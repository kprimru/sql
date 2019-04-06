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

CREATE PROCEDURE [dbo].[ACT_SIGN]
	@actid INT,
	@actdate SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT ACT_ID_CLIENT, ACT_ID, 'ACT', 'Указание даты возврата', CONVERT(VARCHAR(20), @actdate, 104)
		FROM dbo.ActTable
		WHERE ACT_ID = @actid

	UPDATE dbo.ActTable
	SET ACT_SIGN = @actdate
	WHERE ACT_ID = @actid
END
