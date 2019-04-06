USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Income].[INCOME_PERSONAL_DEFAULT_SET]
	@ID_ID		NVARCHAR(MAX),
	@PER_ID		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @ID UNIQUEIDENTIFIER

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)


	DECLARE ID CURSOR LOCAL FOR
		SELECT	ID
		FROM	Common.TableFromList(@ID_ID, ',')
	
	OPEN ID

	FETCH NEXT FROM ID INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_PERSONAL', @ID, @OLD OUTPUT

		DELETE 
		FROM Income.IncomePersonal 
		WHERE IP_ID_INCOME = @ID

		INSERT INTO Income.IncomePersonal(IP_ID_INCOME, IP_ID_PERSONAL, IP_PERCENT)
		SELECT @ID, @PER_ID, Salary.SalaryPercentFromIncome(@ID)
				
		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_PERSONAL', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'INCOME_PERSONAL', '����� ������', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID
END
