USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STREET_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@CITY	UNIQUEIDENTIFIER,
	@NAME	VARCHAR(150),
	@PREFIX	VARCHAR(20),
	@SUFFIX	VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE	dbo.Street
	SET		ST_ID_CITY	=	@CITY,
			ST_NAME		=	@NAME,
			ST_PREFIX	=	@PREFIX,
			ST_SUFFIX	=	@SUFFIX,
			ST_LAST		=	GETDATE()
	WHERE ST_ID = @ID
END