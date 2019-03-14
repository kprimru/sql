USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[SystemNetView]
AS
	SELECT 
		SN_ID, TT_ID, SN_NAME, SNC_NET_COUNT, TT_REG, SNC_ID
	FROM
		dbo.SystemNetTable
		INNER JOIN dbo.SystemNetCountTable ON SNC_ID_SN = SN_ID,
		dbo.TechnolTypeTable
	WHERE TT_REG = 0
	
	UNION ALL

	SELECT 
		SN_ID, TT_ID, TT_NAME, SNC_NET_COUNT, TT_REG, SNC_ID
	FROM
		dbo.SystemNetTable
		INNER JOIN dbo.SystemNetCountTable ON SNC_ID_SN = SN_ID,
		dbo.TechnolTypeTable
	WHERE SNC_NET_COUNT = 0 AND TT_REG = 1