USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[ACTION_UPDATE]
	@ID				UNIQUEIDENTIFIER,
	@NAME			NVARCHAR(128),
	@DELIVERY		SMALLINT,
	@SUPPORT		SMALLINT,
	@DELIVERY_FIXED	MONEY
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Price.Action
	SET NAME			=	@NAME,
		DELIVERY		=	@DELIVERY,
		SUPPORT			=	@SUPPORT,
		DELIVERY_FIXED	=	@DELIVERY_FIXED
	WHERE ID = @ID
END