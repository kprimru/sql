USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_AUDIT_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		CA_ID, CA_DATE, 
		CA_STUDY, CA_STUDY_DATE, 
		CA_SEARCH, CA_SEARCH_NOTE, 
		CA_DUTY, CA_DUTY_DATE, CA_DUTY_AVG, 
		CA_TRANSFER, CA_TRANSFER_NOTE,
		CA_RIVAL, CA_RIVAL_DATE, CA_RIVAL_NOTE,
		CA_SYSTEM, CA_SYSTEM_COUNT, CA_SYSTEM_ER_COUNT,
		CA_INCOME, CA_INCOME_NOTE, CA_NOTE, CA_CONTROL,
		CA_CREATE, CA_USER
	FROM dbo.ClientAudit
	WHERE CA_ID_CLIENT = @CLIENT
	ORDER BY CA_DATE DESC
END