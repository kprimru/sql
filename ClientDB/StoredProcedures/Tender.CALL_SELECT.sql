USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Tender].[CALL_SELECT]
	@TENDER	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, DATE, SUBJECT, SURNAME + ' ' + NAME + ' ' + PATRON + ' ' + PHONE AS FIO, NOTE
	FROM Tender.Call
	WHERE ID_TENDER = @TENDER AND STATUS = 1
	ORDER BY DATE DESC
END
