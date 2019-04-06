USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
Автор:		  Денисов Алексей
Описание:	  Добавить сотрудника клиенту
*/

CREATE PROCEDURE [dbo].[TO_ADDRESS_ADD] 
	@toid INT,
	@streetid SMALLINT,
	@index VARCHAR(20),
	@home VARCHAR(100),
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.TOAddressTable(
								TA_ID_TO, TA_INDEX, TA_ID_STREET, TA_HOME								
								)
	VALUES (
			@toid, @index, @streetid, @home
			)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
