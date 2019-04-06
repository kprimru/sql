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

CREATE PROCEDURE [dbo].[STREET_GET]  
	@streetid INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT ST_NAME, ST_PREFIX, ST_SUFFIX, ST_ID, CT_ID, CT_NAME, ST_ACTIVE
	FROM 
		dbo.StreetTable st LEFT OUTER JOIN
		dbo.CityTable ct ON ct.CT_ID = st.ST_ID_CITY
	WHERE ST_ID = @streetid  

	SET NOCOUNT OFF
END



