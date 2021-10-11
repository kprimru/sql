USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Income].[IncomeMonthString]
(
	@ID	UNIQUEIDENTIFIER
)
RETURNS VARCHAR(100)
--WITH SCHEMABINDING
AS
BEGIN
	DECLARE @PR UNIQUEIDENTIFIER
	DECLARE @MC TINYINT

	SELECT @PR = ID_ID_FIRST_MON, @MC = ID_MON_CNT
	FROM Income.IncomeDetail
	WHERE ID_ID = @ID

	DECLARE @RES VARCHAR(100)
	DECLARE @PR_DATE SMALLDATETIME

	SELECT
		@RES =
			CASE DATEPART(MONTH, PR_BEGIN_DATE)
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
		@PR_DATE = PR_BEGIN_DATE
	FROM Common.PeriodDetail
	WHERE PR_ID_MASTER = @PR

	IF @MC > 1
	BEGIN
		WHILE @MC > 1
		BEGIN
			SET @MC = @MC - 1
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
GO
