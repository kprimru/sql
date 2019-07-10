USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[DIU_DEFAULT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SST_ID, SST_CAPTION,
		NULL AS DISTR,
		NULL AS SH_ID, NULL AS SH_CAPTION,
		NULL AS COMMENT,
		CONVERT(BIT, 0) AS UNREG
	FROM dbo.SystemTypeTable 
	WHERE SST_NAME = 'NCT'
END
