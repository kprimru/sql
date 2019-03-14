USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 30.01.2009
Описание:	  Добавить в справочник статус дистрибутива
*/

CREATE PROCEDURE [dbo].[DISTR_STATUS_ADD] 
	@dsname VARCHAR(50),
	@dsreg TINYINT,
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.DistrStatusTable (DS_NAME, DS_REG, DS_ACTIVE) 
	VALUES (@dsname, @dsreg, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END