USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[COMPLIANCE_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ComplianceTypeID, ComplianceTypeName, ComplianceTypeShortName	
	FROM dbo.ComplianceTypeTable
	WHERE @FILTER IS NULL
		OR ComplianceTypeName LIKE @FILTER 
		OR ComplianceTypeShortName LIKE @FILTER
	ORDER BY ComplianceTypeOrder
END