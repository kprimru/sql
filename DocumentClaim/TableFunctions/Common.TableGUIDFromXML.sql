﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Common].[TableGUIDFromXML]
(
	@SOURCE NVARCHAR(MAX)
)
RETURNS @TBL TABLE
(
	ID UNIQUEIDENTIFIER
)
AS
BEGIN
	DECLARE @XML XML

	SET @XML = CAST(@SOURCE AS XML)

	INSERT INTO @TBL(ID)
		SELECT c.value('(@id)', 'UNIQUEIDENTIFIER')
		FROM @xml.nodes('/root/item') AS a(c)

	RETURN
END
GO
