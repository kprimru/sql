USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SATISFACTION_TYPE_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT STT_NAME, STT_RESULT
	FROM dbo.SatisfactionType
	WHERE STT_ID = @ID
END