USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[ACTIVITY_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(500),
	@CODE	VARCHAR(20),
	@SHORT	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE	dbo.Activity
	SET		AC_NAME		=	@NAME,
			AC_CODE		=	@CODE,
			AC_SHORT	=	@SHORT,
			AC_LAST		=	GETDATE()
	WHERE	AC_ID		=	@ID
END