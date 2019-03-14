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

CREATE PROCEDURE [dbo].[ACT_EDIT_DATE]
	@actid INT,
	@actdate SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT ACT_ID_CLIENT, ACT_ID, 'ACT', 'Изменение даты акта', 'с ' + CONVERT(VARCHAR(20), ACT_DATE, 104) + ' на ' + CONVERT(VARCHAR(20), @actdate, 104)
		FROM dbo.ActTable
		WHERE ACT_ID = @actid AND ACT_DATE <> @actdate

	UPDATE dbo.ActTable
	SET ACT_DATE = @actdate
	WHERE ACT_ID = @actid
END
