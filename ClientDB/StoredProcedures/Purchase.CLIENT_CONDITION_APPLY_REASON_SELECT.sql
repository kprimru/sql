USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_APPLY_REASON_SELECT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		AR_ID, AR_SHORT,
		CONVERT(BIT, 
			ISNULL(
				(
					SELECT COUNT(*)
					FROM 
						Purchase.ClientConditionCard
						INNER JOIN Purchase.ClientConditionApplyReason ON CC_ID = CAR_ID_CC
					WHERE CC_ID_CLIENT = @ID
						AND CC_STATUS = 1
						AND CAR_ID_AR = AR_ID
				), 0)
		) AS AR_CHECKED
	FROM Purchase.ApplyReason
	ORDER BY AR_SHORT
END