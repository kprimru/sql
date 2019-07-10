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

CREATE PROCEDURE [dbo].[COURIER_GET] 
	@courierid SMALLINT  
AS

BEGIN
	SET NOCOUNT ON

	SELECT COUR_NAME, COUR_ID, COUR_ACTIVE, COT_ID, COT_NAME, CT_ID, CT_NAME
	FROM 
		dbo.CourierTable LEFT OUTER JOIN
		dbo.CourierTypeTable ON COT_ID = COUR_ID_TYPE LEFT OUTER JOIN
		dbo.CityTable ON CT_ID = COUR_ID_CITY
	WHERE COUR_ID = @courierid 

	SET NOCOUNT OFF
END



