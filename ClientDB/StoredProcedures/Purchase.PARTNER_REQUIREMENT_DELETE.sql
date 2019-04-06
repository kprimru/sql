USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[PARTNER_REQUIREMENT_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM Purchase.ClientConditionPartnerRequirement
	WHERE CCPR_ID_PR = @ID

	DELETE
	FROM Purchase.PartnerRequirement
	WHERE PR_ID = @ID
END