USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[DateStrToBillStr]
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
