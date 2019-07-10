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

CREATE PROCEDURE [dbo].[TO_DISTR_DELIVERY]
	@tdid VARCHAR(MAX),
	@toid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @list TABLE
		(
			TD_ID INT
		)

	INSERT INTO @list
		SELECT *
		FROM dbo.GET_TABLE_FROM_LIST(@tdid, ',')
	
	UPDATE dbo.TODistrTable
	SET							
		TD_ID_TO = @toid
	WHERE TD_ID IN
		(
			SELECT TD_ID
			FROM @list
		)
END