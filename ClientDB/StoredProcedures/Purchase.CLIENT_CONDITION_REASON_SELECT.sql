USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_REASON_SELECT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		PR_ID, PR_NAME, 
		CONVERT(BIT, 
			ISNULL(
				(
					SELECT COUNT(*)
					FROM 
						Purchase.ClientConditionCard
						INNER JOIN Purchase.ClientConditionReason ON CC_ID = CCR_ID_CC
					WHERE CC_ID_CLIENT = @ID
						AND CC_STATUS = 1
						AND CCR_ID_PR = PR_ID
				), 0)
		) AS PR_CHECKED
	FROM Purchase.PurchaseReason
	ORDER BY PR_NUM
END