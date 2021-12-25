﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[PERSONAL_SALARY_PAY_MON_SET]
	@PS_ID	VARCHAR(MAX),
	@MON	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	DECLARE @ID		UNIQUEIDENTIFIER

	DECLARE ID CURSOR LOCAL FOR
		SELECT ID
		FROM Common.TableFromList(@PS_ID, ',')

	OPEN ID

	FETCH NEXT FROM ID INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_SALARY', @ID, @OLD OUTPUT

		UPDATE	Salary.PersonalSalary
		SET		PS_ID_PAY	=	@MON
		WHERE	PS_ID		=	@ID

		EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_SALARY', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'PERSONAL_SALARY', 'Изменение месяца выплаты', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID
END
GO
GRANT EXECUTE ON [Salary].[PERSONAL_SALARY_PAY_MON_SET] TO rl_salary_w;
GO
