USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Добавить должность в справочник
*/

CREATE PROCEDURE [dbo].[POSITION_ADD] 
	@positionname VARCHAR(150),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.PositionTable(POS_NAME, POS_ACTIVE) 
	VALUES (@positionname, @active)

	IF @returnvalue = 1
	  SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
