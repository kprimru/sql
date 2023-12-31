USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[TableStringNewFromXML]
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
		SELECT c.value('(@id)[1]', 'VARCHAR(100)')
		FROM @xml.nodes('/root/item') AS a(c)

	RETURN
END
GO
