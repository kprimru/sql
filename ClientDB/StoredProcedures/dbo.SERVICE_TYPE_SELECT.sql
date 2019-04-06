USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ServiceTypeID, ServiceTypeName, ServiceTypeShortName, ServiceTypeVisit, ServiceTypeDefault
	FROM dbo.ServiceTypeTable
	WHERE 
		ServiceTypeActive = 1
		AND
			(
				@FILTER IS NULL
				OR ServiceTypeName LIKE @FILTER
				OR ServiceTypeShortName LIKE @FILTER
			)
	ORDER BY ServiceTypeName
END