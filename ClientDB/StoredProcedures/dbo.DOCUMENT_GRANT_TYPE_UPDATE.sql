USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DOCUMENT_GRANT_TYPE_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(50),
	@DEF	BIT
AS
BEGIN
	SET NOCOUNT ON;

	IF @DEF = 1
		UPDATE dbo.DocumentGrantType
		SET DEF = 0
		WHERE ID <> @ID

	UPDATE	dbo.DocumentGrantType
	SET		NAME	=	@NAME,
			DEF		=	@DEF
	WHERE	ID		=	@ID
END