USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISTR_TYPE_SELECT_OFFLINE]
	@FILTER	VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DistrTypeID, DistrTypeName, DistrTypeShortName
	FROM dbo.DistrTypeTable
	WHERE (@FILTER IS NULL
		OR DistrTypeName LIKE @FILTER
		OR DistrTypeShortName LIKE @FILTER)
		AND (DistrTypeBaseCheck = 1)
	ORDER BY DistrTypeOrder
END

