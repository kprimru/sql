﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SplitString]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[SplitString] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
ALTER FUNCTION [dbo].[SplitString]
(
	@STRING	VARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
(
	WITH Proposition
		(
			[Order], Word, Proposition
		) AS
		(
			SELECT
				1,
				SUBSTRING(Proposition, 0, CHARINDEX(' ', Proposition)),
				LTRIM(SUBSTRING(Proposition, CHARINDEX(' ', Proposition) + 1, LEN(Proposition)))
			FROM
				(
					SELECT
						LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(@STRING, Char(9), ' '), Char(10), ' '), Char(13), ' '))) + ' ' AS Proposition
				) AS Proposition

			UNION	ALL

			SELECT
				[Order] + 1,
				SUBSTRING(Proposition, 0, CHARINDEX(' ', Proposition)),
				LTRIM(SUBSTRING(Proposition, CHARINDEX(' ', Proposition) + 1, LEN(Proposition)))
			FROM Proposition
			WHERE CHARINDEX(' ', Proposition) > 0
		)
		SELECT [Order], Word
		FROM Proposition
)
GO
