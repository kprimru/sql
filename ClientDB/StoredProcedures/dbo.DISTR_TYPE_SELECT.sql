USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISTR_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DistrTypeID, DistrTypeName, DistrTypeOrder, DistrTypeFull, DistrTypeCode, DistrTypeBaseCheck
	FROM dbo.DistrTypeTable
	WHERE @FILTER IS NULL
		OR DistrTypeName LIKE @FILTER
		OR DistrTypeFull LIKE @FILTER
		OR DistrTypeCode LIKE @FILTER
	ORDER BY DistrTypeOrder
END
