USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_ORI_GET]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		CO_NAME, CO_VISIT, CO_INFORMATION, 
		CO_RES_NAME, CO_RES_PHONE, CO_RES_POSITION, CO_RES_PLACE, 
		CO_STUDY, CO_CLAIM, CO_CURR_STATUS, CO_PLAN_ACTION, 
		CO_RESULT, CO_RIVAL, CO_NOTE
	FROM dbo.ClientOri
	WHERE CO_ID_CLIENT = @CLIENT
		AND CO_STATUS = 1
END