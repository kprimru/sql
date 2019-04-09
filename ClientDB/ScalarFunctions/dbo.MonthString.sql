USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[MonthString]
(
	@DT	DATETIME
)
RETURNS VARCHAR(100)
WITH SCHEMABINDING
AS
BEGIN

	RETURN CASE DATEPART(MONTH, @DT)
			WHEN 1 THEN '������'
			WHEN 2 THEN '�������'
			WHEN 3 THEN '����'
			WHEN 4 THEN '������'
			WHEN 5 THEN '���'
			WHEN 6 THEN '����'
			WHEN 7 THEN '����'
			WHEN 8 THEN '������'
			WHEN 9 THEN '��������'
			WHEN 10 THEN '�������'
			WHEN 11 THEN '������'
			WHEN 12 THEN '�������'
			ELSE NULL
		END + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, @DT))
END
