﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Salary].[PERSONAL_SALARY_SET_PAYED]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Salary].[PERSONAL_SALARY_SET_PAYED]  AS SELECT 1')
GO
ALTER PROCEDURE [Salary].[PERSONAL_SALARY_SET_PAYED]
	@ID_ID		VARCHAR(MAX),
	@PAYED		BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	DECLARE @ID		UNIQUEIDENTIFIER

	DECLARE ID CURSOR LOCAL FOR
		SELECT ID
		FROM Common.TableFromList(@ID_ID, ',')

	OPEN ID

	FETCH NEXT FROM ID INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_SALARY', @ID, @OLD OUTPUT

		UPDATE	Salary.PersonalSalary
		SET		PS_PAYED	=	@PAYED
		WHERE	PS_ID		=	@ID

		EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_SALARY', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'PERSONAL_SALARY', 'Указание признака "выплачено"', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID
END
GO
GRANT EXECUTE ON [Salary].[PERSONAL_SALARY_SET_PAYED] TO rl_salary_w;
GO
