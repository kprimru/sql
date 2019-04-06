USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Purchase].[TRADEMARK_LAST]
	@LAST	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @LAST = MAX(TM_LAST)
	FROM Purchase.Trademark
END