﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TableStringFromXML]', 'TF') IS NULL EXEC('CREATE FUNCTION [dbo].[TableStringFromXML] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
CREATE OR ALTER FUNCTION [dbo].[TableStringFromXML]
	(
		@SOURCE NVARCHAR(MAX)
	)
RETURNS @TBL TABLE
	(
		ID VARCHAR(100)
	)
AS
BEGIN
	DECLARE @XML XML

	SET @XML = CAST(@SOURCE AS XML)

	INSERT INTO @TBL(ID)
		SELECT c.value('(.)', 'VARCHAR(100)')
		FROM @xml.nodes('/LIST/ITEM') AS a(c)

	RETURN
END
GO
