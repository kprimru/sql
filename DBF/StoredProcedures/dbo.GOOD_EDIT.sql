USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[GOOD_EDIT]
	@id SMALLINT,
	@name VARCHAR(150),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.GoodTable
	SET GD_NAME = @name,
		GD_ACTIVE = @active
	WHERE GD_ID = @id
END

