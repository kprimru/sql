USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[ISO_WEEK]
(
	@DATE	DATETIME
)
RETURNS INT
AS
BEGIN
   DECLARE @ISOweek INT
   SET @ISOweek = DATEPART(wk, @DATE) + 1 - DATEPART(wk, CAST(DATEPART(yy, @DATE) as CHAR(4)) + '0104')

   IF (@ISOweek = 0)
      SET @ISOweek = dbo.ISO_WEEK(CAST(DATEPART(yy, @DATE) - 1 AS CHAR(4)) + '12' + CAST(24 + DATEPART(DAY, @DATE) AS CHAR(2))) + 1

   IF ((DATEPART(mm, @DATE) = 12) AND
      ((DATEPART(dd, @DATE) - DATEPART(dw, @DATE)) >= 28))
      SET @ISOweek = 1

   RETURN(@ISOweek)
END
GO
