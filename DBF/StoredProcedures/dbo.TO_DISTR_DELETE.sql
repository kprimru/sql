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

CREATE PROCEDURE [dbo].[TO_DISTR_DELETE]
	@tdid INT	
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.TODistrTable WHERE TD_ID = @tdid
END