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

CREATE PROCEDURE [dbo].[GLOBAL_SETTINGS_TRY_DELETE]
	@gsid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''	

	SELECT @res AS RES, @txt AS TXT
END

