USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[CLAIM_CANCEL_REASON_LAST]
	@LAST	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @LAST = MAX(CCR_LAST)
	FROM Purchase.ClaimCancelReason
END