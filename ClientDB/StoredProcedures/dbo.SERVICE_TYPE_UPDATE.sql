USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_TYPE_UPDATE]
	@ID			INT,
	@NAME		VARCHAR(100),
	@SHORT		VARCHAR(50),
	@VISIT		BIT,
	@DEFAULT	BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ServiceTypeTable
	SET ServiceTypeName = @NAME,
		ServiceTypeShortName = @SHORT,
		ServiceTypeVisit = @VISIT,
		ServiceTypeDefault = @DEFAULT
	WHERE ServiceTypeID = @ID
END