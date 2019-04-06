USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SUBHOST_LIST_GET]
	@SH_ID VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	IF @SH_ID IS NULL
		SELECT SH_ID, SH_SHORT_NAME
		FROM dbo.SubhostTable
		WHERE SH_ID = 11
		ORDER BY SH_ORDER
	ELSE
		SELECT SH_ID, SH_SHORT_NAME
		FROM 
			dbo.SubhostTable INNER JOIN
			dbo.GET_TABLE_FROM_LIST(@SH_ID, ',') ON Item = SH_ID
		ORDER BY SH_ORDER
END