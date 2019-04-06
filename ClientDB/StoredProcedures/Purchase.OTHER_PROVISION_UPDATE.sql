USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[OTHER_PROVISION_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(4000),
	@SHORT	VARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Purchase.OtherProvision
	SET OP_NAME		=	@NAME,
		OP_SHORT	=	@SHORT,
		OP_LAST		=	GETDATE()
	WHERE OP_ID = @ID
END