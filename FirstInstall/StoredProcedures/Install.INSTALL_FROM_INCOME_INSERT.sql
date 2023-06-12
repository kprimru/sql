﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Install].[INSTALL_FROM_INCOME_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Install].[INSTALL_FROM_INCOME_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Install].[INSTALL_FROM_INCOME_INSERT]
	@ID_LIST	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;


	DECLARE INCOME CURSOR LOCAL FOR
		SELECT ID
		FROM Common.TableFromList(@ID_LIST, ',')

	DECLARE @ID_ID		UNIQUEIDENTIFIER

	DECLARE @INS_ID		UNIQUEIDENTIFIER
	DECLARE @CL_ID		UNIQUEIDENTIFIER
	DECLARE @VD_ID		UNIQUEIDENTIFIER
	DECLARE @INS_DATE	SMALLDATETIME


	DECLARE @IND_ID		UNIQUEIDENTIFIER
	DECLARE	@SYS_ID		UNIQUEIDENTIFIER
	DECLARE @DT_ID		UNIQUEIDENTIFIER
	DECLARE @NT_ID		UNIQUEIDENTIFIER
	DECLARE @TT_ID		UNIQUEIDENTIFIER

	DECLARE @COUNT		TINYINT

	OPEN INCOME

	FETCH NEXT FROM INCOME INTO @ID_ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @INS_ID = NULL
		-- Пункт 1. Создать запись в Install (Master), если нужно
		SELECT @INS_ID = INS_ID
		FROM
			Install.Install INNER JOIN
			Income.Incomes ON IN_ID_CLIENT = INS_ID_CLIENT
						AND IN_ID_VENDOR = INS_ID_VENDOR
						AND IN_DATE = INS_DATE INNER JOIN
			Income.IncomeDetail ON ID_ID_INCOME = IN_ID
		WHERE ID_ID = @ID_ID

		IF @INS_ID IS NULL
		BEGIN
			SELECT
				@INS_DATE	=	IN_DATE,
				@CL_ID		=	IN_ID_CLIENT,
				@VD_ID		=	IN_ID_VENDOR
			FROM
				Income.Incomes INNER JOIN
				Income.IncomeDetail ON ID_ID_INCOME = IN_ID
			WHERE ID_ID = @ID_ID

			EXEC Install.INSTALL_INSERT @CL_ID, @VD_ID, @INS_DATE, @INS_ID OUTPUT
		END

		-- Пункт 2. Занести запись в InstallDetail

		SELECT @IND_ID = IND_ID
		FROM Install.InstallDetail
		WHERE IND_ID_INCOME = @ID_ID

		IF @IND_ID IS NULL
		BEGIN
			SELECT
				@SYS_ID =	ID_ID_SYSTEM,
				@DT_ID	=	ID_ID_TYPE,
				@NT_ID	=	ID_ID_NET,
				@TT_ID	=	ID_ID_TECH,
				@COUNT	=	ID_COUNT
			FROM Income.IncomeDetail
			WHERE ID_ID = @ID_ID

			EXEC Install.INSTALL_DETAIL_INSERT @INS_ID, @ID_ID, @SYS_ID, @DT_ID, @NT_ID, @TT_ID, @COUNT, 0
		END

		FETCH NEXT FROM INCOME INTO @ID_ID
	END

	CLOSE INCOME
	DEALLOCATE INCOME
END
GO
GRANT EXECUTE ON [Install].[INSTALL_FROM_INCOME_INSERT] TO rl_install_i;
GO
