USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[PARTNER_REQUIREMENT_INSERT]
	@NAME	VARCHAR(4000),
	@SHORT	VARCHAR(200),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO Purchase.PartnerRequirement(PR_NAME, PR_SHORT)
		OUTPUT inserted.PR_ID INTO @TBL
		VALUES(@NAME, @SHORT)
		
	SELECT @ID = ID
	FROM @TBL
END