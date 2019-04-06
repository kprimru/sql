USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_QUEST_PREPARE]
	@CLIENT	INT,
	@TEXT	VARCHAR(100) = NULL OUTPUT,
	@COLOR	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SET @TEXT = NULL
	
	SET @COLOR = 0
END