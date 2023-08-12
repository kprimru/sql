USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[WeekDateName]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[WeekDateName] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE OR ALTER FUNCTION [dbo].[WeekDateName]
(
	@Value	DateTime
)
RETURNS VARCHAR(100)
AS
BEGIN
	RETURN
		(
			SELECT [Name] = D.[DayName]
			FROM [dbo].[DayTable] AS D
			WHERE D.[DayOrder] = DatePart(WeekDay, @Value)
		);
END
GO
