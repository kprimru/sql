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

CREATE PROCEDURE [dbo].[GOOD_DELETE]
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM dbo.GoodTable WHERE GD_ID = @id
END
