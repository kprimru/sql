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

CREATE PROCEDURE [dbo].[ACT_CHECK_PRINT]
	@actid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ActTable 
	SET ACT_PRINT = 1
	WHERE ACT_ID = @actid
END
