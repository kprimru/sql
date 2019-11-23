USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[StringSplit]
(
	@STRING		VarChar(MAX),
	@Delimiter	VarCHar(10)
)
RETURNS TABLE
AS
RETURN
(
	WITH Proposition([Order], String, Proposition) AS 
	(	
		SELECT	          
			1,
			SubString(Proposition, 0, CharIndex(@Delimiter, Proposition)), 
			LTrim(SubString(Proposition, CharIndex(@Delimiter, Proposition) + 1, Len(Proposition)))
		FROM	
			(
				SELECT 
					LTrim(RTrim(Replace(Replace(Replace(@STRING, Char(9), @Delimiter), Char(10), @Delimiter), Char(13), @Delimiter))) + @Delimiter AS Proposition
			) AS Proposition
				
		UNION ALL

		SELECT	
			[Order] + 1,
			SubString(Proposition, 0, CharIndex(@Delimiter, Proposition)), 
			LTrim(SubString(Proposition, CharIndex(@Delimiter, Proposition) + 1, Len(Proposition)))
		FROM Proposition
		WHERE CharIndex(@Delimiter, Proposition) > 0
	)	
	SELECT [Order], String, Proposition
	FROM Proposition
)
