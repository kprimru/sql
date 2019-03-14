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

CREATE PROCEDURE [dbo].[COURIER_SELECT]   
	@active BIT = NULL
AS

BEGIN
	SET NOCOUNT ON
	
	SELECT COUR_NAME, COUR_ID, COT_NAME
	FROM 
		dbo.CourierTable LEFT OUTER JOIN
		dbo.CourierTypeTable ON COT_ID = COUR_ID_TYPE
	WHERE COUR_ACTIVE = ISNULL(@active, COUR_ACTIVE)
	ORDER BY COUR_NAME

	SET NOCOUNT OFF
END



