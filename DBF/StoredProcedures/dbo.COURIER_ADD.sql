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

CREATE PROCEDURE [dbo].[COURIER_ADD] 
	@couriername VARCHAR(150),
	@type SMALLINT,
	@active BIT = 1,
	@oldcode INT = NULL,
	@city SMALLINT = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.CourierTable (COUR_NAME, COUR_ID_TYPE, COUR_ID_CITY, COUR_ACTIVE, COUR_OLD_CODE) 
	VALUES (@couriername, @type, @city, @active, @oldcode)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END