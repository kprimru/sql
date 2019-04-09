USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[OS_FAMILY_LAST]
	@LAST	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @LAST = MAX(OF_LAST)
	FROM USR.OSFamily	
END