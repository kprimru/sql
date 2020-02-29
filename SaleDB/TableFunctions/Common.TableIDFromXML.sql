USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Common].[TableIDFromXML]
	(
		@SOURCE NVARCHAR(MAX)
	)
RETURNS @TBL TABLE
	(
		ID Int
	)
AS
BEGIN
	DECLARE @XML XML

	SET @XML = CAST(@SOURCE AS XML)

	INSERT INTO @TBL(ID)
		SELECT c.value('(@id)', 'Int')
		FROM @xml.nodes('/root/item') AS a(c)

	RETURN
END