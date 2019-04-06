USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[KD_VERSION_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(128),
	@SHORT	NVARCHAR(64),
	@ACTIVE	BIT,
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.KDVersion
	SET NAME	=	@NAME,
		SHORT	=	@SHORT,
		ACTIVE	=	@ACTIVE,
		START	=	@START,
		FINISH	=	@FINISH,
		LAST	=	GETDATE()
	WHERE ID = @ID
END
