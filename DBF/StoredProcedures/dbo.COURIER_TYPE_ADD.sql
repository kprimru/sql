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

CREATE PROCEDURE [dbo].[COURIER_TYPE_ADD] 
	@name VARCHAR(50),
	@active BIT = 1,	
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.CourierTypeTable (COT_NAME, COT_ACTIVE) 
	VALUES (@name, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
