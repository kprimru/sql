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

CREATE PROCEDURE [dbo].[PAY_COEF_GET] 
	@id SMALLINT  
AS

BEGIN
	SET NOCOUNT ON

	SELECT PC_START, PC_END, PC_VALUE, PC_ID, PC_ACTIVE
	FROM dbo.PayCoefTable 
	WHERE PC_ID = @id 

	SET NOCOUNT OFF
END
