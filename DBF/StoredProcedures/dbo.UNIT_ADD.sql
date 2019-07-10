USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Дата создания: 24.09.2008
Описание:	  Добавить тип системы 
               клиента в справочник
*/

CREATE PROCEDURE [dbo].[UNIT_ADD]
	@name VARCHAR(100),
	@okei VARCHAR(50),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.UnitTable(UN_NAME, UN_OKEI, UN_ACTIVE) 
	VALUES (@name, @okei, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
