USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[POST_TYPE_SELECT]
	@FILTER VARCHAR(100) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PostTypeID, PostTypeName
	FROM dbo.PostTypeTable
	WHERE @FILTER IS NULL
		OR PostTypeName LIKE @FILTER
	ORDER BY PostTypeName
END