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

CREATE PROCEDURE [dbo].[COURIER_TYPE_GET] 
	@id SMALLINT  
AS

BEGIN
	SET NOCOUNT ON

	SELECT COT_NAME, COT_ID, COT_ACTIVE
	FROM dbo.CourierTypeTable 
	WHERE COT_ID = @id 

	SET NOCOUNT OFF
END
