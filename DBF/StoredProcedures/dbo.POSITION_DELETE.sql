USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Удалить из справочника должность 
               с указанным кодом
*/

CREATE PROCEDURE [dbo].[POSITION_DELETE] 
	@positionid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.PositionTable 
	WHERE POS_ID = @positionid

	SET NOCOUNT OFF
END