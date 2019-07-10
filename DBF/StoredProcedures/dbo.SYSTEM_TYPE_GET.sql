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

CREATE PROCEDURE [dbo].[SYSTEM_TYPE_GET] 
	@systemtypeid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		a.SST_ID, a.SST_NAME, a.SST_CAPTION, a.SST_REPORT, a.SST_LST, a.SST_ACTIVE,
		a.SST_ORDER, b.SST_ID AS MOS_ID, b.SST_CAPTION AS MOS_NAME,
		c.SST_ID AS SUB_ID, c.SST_CAPTION AS SUB_NAME,
		d.SST_ID AS SHT_ID, d.SST_CAPTION AS SHT_NAME,
		e.SST_ID AS SDHT_ID, e.SST_CAPTION AS SDHT_NAME,
		a.SST_COEF, a.SST_CALC, a.SST_KBU
	FROM 
		dbo.SystemTypeTable a LEFT OUTER JOIN
		dbo.SystemTypeTable b ON a.SST_ID_MOS = b.SST_ID LEFT OUTER JOIN
		dbo.SystemTypeTable c ON a.SST_ID_SUB = c.SST_ID LEFT OUTER JOIN
		dbo.SystemTypeTable d ON a.SST_ID_HOST = d.SST_ID LEFT OUTER JOIN
		dbo.SystemTypeTable e ON a.SST_ID_DHOST = e.SST_ID
	WHERE a.SST_ID = @systemtypeid

	SET NOCOUNT OFF
END








