USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[REGION_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(100),
	@PREFIX	VARCHAR(20),
	@SUFFIX	VARCHAR(20),
	@NUM	TINYINT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.Region
	SET RG_NAME		=	@NAME,
		RG_PREFIX	=	@PREFIX,
		RG_SUFFIX	=	@SUFFIX,
		RG_NUM		=	@NUM,
		RG_LAST		=	GETDATE()
	WHERE RG_ID		=	@ID
END