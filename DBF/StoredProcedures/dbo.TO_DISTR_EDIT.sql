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

CREATE PROCEDURE [dbo].[TO_DISTR_EDIT]
	@tdid INT,
	@toid INT,
	@distrid INT	
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.TODistrTable
	SET							
		TD_ID_TO = @toid, 
		TD_ID_DISTR = @distrid
	WHERE TD_ID = @tdid
END