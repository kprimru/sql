﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[TableStringFromXML]', 'TF') IS NULL EXEC('CREATE FUNCTION [Common].[TableStringFromXML] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
CREATE FUNCTION [Common].[TableStringFromXML]
	(
		@SOURCE NVARCHAR(MAX)
	)
RETURNS @TBL TABLE
	(
		ID NVARCHAR(128)
	)
AS
BEGIN
	DECLARE @XML XML

	SET @XML = CAST(@SOURCE AS XML)

	INSERT INTO @TBL(ID)
		SELECT c.value('(@id)', 'NVARCHAR(128)')
		FROM @xml.nodes('/root/item') AS a(c)

	RETURN
END
GO
