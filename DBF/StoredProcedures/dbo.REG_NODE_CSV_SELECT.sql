USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[REG_NODE_CSV_SELECT]
	@SH	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SH_SHORT VARCHAR(50)

	SELECT TOP 1 @SH_SHORT = SH_LST_NAME
	FROM 
		dbo.SubhostTable INNER JOIN
		dbo.GET_TABLE_FROM_LIST(@SH, ',') ON SH_ID = Item
	
	SELECT *
	FROM dbo.RegNodeTable
	WHERE RN_COMMENT LIKE '(' + @SH_SHORT + ')%'
END