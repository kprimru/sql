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

CREATE PROCEDURE [dbo].[SYSTEM_NET_GET] 
	@id INT
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT SN_NAME, SN_FULL_NAME, SN_COEF, SN_ORDER, SN_CALC, SN_ID, SN_ACTIVE
	FROM dbo.SystemNetTable 
	WHERE SN_ID = @id 

	SET NOCOUNT OFF
END









