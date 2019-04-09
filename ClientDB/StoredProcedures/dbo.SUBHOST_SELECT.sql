USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SUBHOST_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SH_ID, SH_NAME, SH_REG
	FROM dbo.Subhost
	WHERE @FILTER IS NULL
		OR SH_NAME LIKE @FILTER
		OR SH_REG LIKE @FILTER
	ORDER BY SH_REG
END
