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

CREATE PROCEDURE [dbo].[TO_PERSONAL_CHECK_REPORT_POS] 
	@toid INT,
	@reportposid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	SELECT TP_ID 
	FROM dbo.TOPersonalTable
	WHERE TP_ID_TO = @toid AND TP_ID_RP = @reportposid

	SET NOCOUNT OFF
END

