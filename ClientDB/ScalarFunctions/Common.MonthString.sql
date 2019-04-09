USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Common].[MonthString]
(
	@MONTH	UNIQUEIDENTIFIER,
	@DELTA	INT
)
RETURNS NVARCHAR(128)
AS
BEGIN	
	DECLARE @RES VARCHAR(128)
	DECLARE @PR_DATE SMALLDATETIME	

	SELECT 
		@RES = 
			CASE DATEPART(MONTH, START)
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
				ELSE '-'
			END, 
		@PR_DATE = START
	FROM Common.Period
	WHERE ID = @MONTH

	IF @DELTA > 1
	BEGIN
		WHILE @DELTA > 1
		BEGIN
			SET @DELTA = @DELTA - 1
			SET @PR_DATE = DATEADD(MONTH, 1, @PR_DATE)
		END
		SET @RES = @RES + '-' + CASE DATEPART(MONTH, @PR_DATE)
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
				ELSE '-'
			END
	END	

	RETURN @RES
END