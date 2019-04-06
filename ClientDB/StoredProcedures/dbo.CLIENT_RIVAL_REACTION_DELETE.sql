USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_RIVAL_REACTION_DELETE]
	@CRR_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ClientRivalReaction
	SET CRR_ACTIVE = 0
	WHERE CRR_ID = @CRR_ID
END