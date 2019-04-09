USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[PARTNER_REQUIREMENT_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PR_NAME, PR_SHORT
	FROM Purchase.PartnerRequirement
	WHERE PR_ID = @ID
END