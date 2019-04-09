USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[PURCHASE_REASON_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PR_NAME, PR_NUM
	FROM Purchase.PurchaseReason
	WHERE PR_ID = @ID
END