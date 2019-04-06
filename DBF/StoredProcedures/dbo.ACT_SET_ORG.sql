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
CREATE PROCEDURE [dbo].[ACT_SET_ORG]
	@actid INT,
	@orgid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ActTable
	SET ACT_ID_ORG = @orgid
	WHERE ACT_ID = @actid
END