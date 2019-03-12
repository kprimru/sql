USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[COMPLIANCE_TYPE_GET]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ComplianceTypeName, ComplianceTypeShortName, ComplianceTypeOrder
	FROM dbo.ComplianceTypeTable
	WHERE ComplianceTypeID = @ID
END