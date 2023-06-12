USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DateStrToBillStr]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[DateStrToBillStr] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[DateStrToBillStr]
(
	@Value VarChar(100)
)
RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE @Date Date = Convert(Date, @Value, 112);

	RETURN Cast(DatePart(Day, @Date) AS VarChar(100)) + ' ' + DateName(Month, @Date) + ', ' + Cast(DatePart(Year, @Date) AS VarChar(100));
END
GO
