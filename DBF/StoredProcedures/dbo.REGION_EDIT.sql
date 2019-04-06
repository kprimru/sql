USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Изменить данные о регионе с 
               указанным кодом
*/

CREATE PROCEDURE [dbo].[REGION_EDIT] 
	@regionid SMALLINT,
	@regionname VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.RegionTable 
	SET RG_NAME = @regionname,
		RG_ACTIVE = @active
	WHERE RG_ID = @regionid

	SET NOCOUNT OFF
END