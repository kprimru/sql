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

CREATE PROCEDURE [dbo].[GOOD_SELECT]
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT GD_ID, GD_NAME
	FROM 
		dbo.GoodTable 
	WHERE GD_ACTIVE = ISNULL(@active, GD_ACTIVE)
END

