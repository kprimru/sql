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

CREATE PROCEDURE [dbo].[TO_CHECK_NUM]
	@num INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TO_ID
	FROM dbo.TOTable
	WHERE TO_NUM = @num
END
