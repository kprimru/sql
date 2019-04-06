USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[CLIENT_DISTR_STATUS_CHANGE]
	@tdid VARCHAR(MAX),
	@status SMALLINT
AS
BEGIN
	SET NOCOUNT ON;	
	
	UPDATE dbo.ClientDistrTable
	SET							
		CD_ID_SERVICE = @STATUS
	WHERE CD_ID IN
		(
			SELECT *
			FROM dbo.GET_TABLE_FROM_LIST(@tdid, ',')
		)
END
