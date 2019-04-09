USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[GOOD_REQUIREMENT_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(4000),
	@SHORT	VARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Purchase.GoodRequirement
	SET GR_NAME		=	@NAME,
		GR_SHORT	=	@SHORT,
		GR_LAST		=	GETDATE()
	WHERE GR_ID = @ID
END