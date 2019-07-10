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

CREATE PROCEDURE [dbo].[ACT_CHECK_INVOICE]
	@actid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ACT_DATE, ACT_ID
	FROM dbo.ActTable
	WHERE ACT_ID_INVOICE IS NOT NULL AND ACT_ID = @actid
		AND 1=0
END

