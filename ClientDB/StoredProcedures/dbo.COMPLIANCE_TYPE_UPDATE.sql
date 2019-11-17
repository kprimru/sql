USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[COMPLIANCE_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@SHORT	VARCHAR(100),
	@ORDER	INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ComplianceTypeTable
	SET ComplianceTypeName = @NAME,
		ComplianceTypeShortName = @SHORT,
		ComplianceTypeOrder = @ORDER
	WHERE ComplianceTypeID = @ID
END