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

CREATE PROCEDURE [dbo].[CLIENT_PERSONAL_CHECK_REPORT_POS] 
	@clientid INT,
	@reportposid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	SELECT PER_ID 
	FROM dbo.ClientPersonalTable
	WHERE PER_ID_CLIENT = @clientid AND PER_ID_REPORT_POS = @reportposid

	SET NOCOUNT OFF
END
