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

CREATE PROCEDURE [dbo].[PLUG_DEL_ACT]
	@actid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ActTable
	SET ACT_ID_INVOICE = NULL		
	WHERE ACT_ID = @actid
END
