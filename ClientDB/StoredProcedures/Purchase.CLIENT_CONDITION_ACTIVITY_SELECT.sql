USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Purchase].[CLIENT_CONDITION_ACTIVITY_SELECT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		AC_ID, AC_NAME, AC_CODE + ' ' + ISNULL(AC_SHORT, AC_NAME) AS AC_SEARCH,
		CONVERT(BIT, 
			ISNULL(
				(
					SELECT COUNT(*)
					FROM 
						Purchase.ClientConditionCard
						INNER JOIN Purchase.ClientConditionActivity ON CC_ID = CCA_ID_CC
					WHERE CC_ID_CLIENT = @ID
						AND CC_STATUS = 1
						AND CCA_ID_AC = AC_ID
				), 0)
		) AS AC_CHECKED
	FROM dbo.Activity
	ORDER BY 
		dbo.StringDelimiterPartInt(AC_CODE, '.', 1),
		dbo.StringDelimiterPartInt(AC_CODE, '.', 2),
		dbo.StringDelimiterPartInt(AC_CODE, '.', 3),
		dbo.StringDelimiterPartInt(AC_CODE, '.', 4)
END