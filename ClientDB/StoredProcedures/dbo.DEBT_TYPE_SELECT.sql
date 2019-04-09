USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DEBT_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, SHORT, NAME
	FROM dbo.DebtType
	WHERE @FILTER IS NULL
		OR NAME LIKE @FILTER
		OR SHORT LIKE @FILTER
	ORDER BY SHORT
END
