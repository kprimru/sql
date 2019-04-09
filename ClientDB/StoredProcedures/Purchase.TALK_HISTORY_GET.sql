USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[TALK_HISTORY_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON

	SELECT TH_DATE, TH_WHO, TH_PERSONAL, TH_THEME
	FROM Purchase.TalkHistory
	WHERE TH_ID = @ID
END