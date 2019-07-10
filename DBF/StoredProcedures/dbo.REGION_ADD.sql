USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Добавить регион в справочник
*/

CREATE PROCEDURE [dbo].[REGION_ADD] 
	@regionname VARCHAR(100),
	@active BIT = 1,
	@oldcode INT = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.RegionTable(RG_NAME, RG_ACTIVE, RG_OLD_CODE) 
	VALUES (@regionname, @active, @oldcode)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END