USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[COURIER_TYPE_CHECK_NAME] 
	@name VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT COT_ID
	FROM dbo.CourierTypeTable
	WHERE COT_NAME = @name

	SET NOCOUNT OFF
END
