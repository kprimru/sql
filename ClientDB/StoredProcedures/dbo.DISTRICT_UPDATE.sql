USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[DISTRICT_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@CITY	UNIQUEIDENTIFIER,
	@NAME	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE	dbo.District
	SET		DS_ID_CITY	=	@CITY,
			DS_NAME		=	@NAME,
			DS_LAST		=	GETDATE()
	WHERE DS_ID = @ID
END