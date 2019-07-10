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

CREATE PROCEDURE [dbo].[PRICE_GROUP_SELECT]   
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT PG_ID, PG_NAME
	FROM 		
		dbo.PriceGroupTable 
	WHERE PG_ACTIVE = ISNULL(@active, PG_ACTIVE)
	ORDER BY PG_NAME

	SET NOCOUNT OFF
END
