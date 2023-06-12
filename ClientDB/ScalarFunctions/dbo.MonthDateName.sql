USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[MonthDateName]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[MonthDateName] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[MonthDateName]
(
	@Value	DateTime
)
RETURNS VARCHAR(100)
AS
BEGIN
	RETURN
		(
			SELECT Upper(SubString(M.[Name], 1, 1)) + SubString(M.[Name], 2, Len(M.[Name]))
			FROM
			(
				SELECT [Name] = M.[NAME]
				FROM [dbo].[Month] AS M
				WHERE M.[NUM] = DatePart(Month, @Value)
			) AS M
		);
END
GO
