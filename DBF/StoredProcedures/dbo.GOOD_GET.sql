USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[GOOD_GET]
	@goodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT GD_ID, GD_NAME, GD_ACTIVE
	FROM 
		dbo.GoodTable 
	WHERE GD_ID = @goodid
END

