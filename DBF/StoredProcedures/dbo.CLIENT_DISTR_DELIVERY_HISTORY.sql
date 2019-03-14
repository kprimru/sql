USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:         Денисов Алексей
Описание:      
*/

CREATE PROCEDURE [dbo].[CLIENT_DISTR_DELIVERY_HISTORY] 
	@id INT,
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @distrid INT

	SELECT @distrid = CD_ID_DISTR
	FROM dbo.ClientDistrTable
	WHERE CD_ID = @id

	UPDATE dbo.ClientDistrTable 
	SET CD_ID_CLIENT = @clientid
	WHERE CD_ID = @id
	
	--удалить из ТО этот дистрибутив

	DELETE 
	FROM dbo.TODistrTable
	WHERE TD_ID_DISTR = 
		(
			SELECT CD_ID_DISTR 
			FROM  dbo.ClientDistrTable 
			WHERE CD_ID = @id	
		)

	IF (SELECT COUNT(*) FROM dbo.TOTable WHERE TO_ID_CLIENT = @clientid) = 1
		BEGIN
			INSERT INTO dbo.TODistrTable (TD_ID_TO, TD_ID_DISTR)
			SELECT
				(
					SELECT TO_ID 
					FROM dbo.TOTable 
					WHERE TO_ID_CLIENT = @clientid
				),
				(
					SELECT CD_ID_DISTR 
					FROM  dbo.ClientDistrTable 
					WHERE CD_ID = @id 
				)				
		END

	SET NOCOUNT OFF
END






