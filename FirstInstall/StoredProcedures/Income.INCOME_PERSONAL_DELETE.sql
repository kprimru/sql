USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Income].[INCOME_PERSONAL_DELETE]
	@ID_ID		VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID UNIQUEIDENTIFIER

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)


	DECLARE ID CURSOR LOCAL FOR
		SELECT	IP_ID
		FROM	Income.IncomePersonal
		WHERE	IP_ID_INCOME	IN
			(
				SELECT ID
				FROM Common.TableFromList(@ID_ID, ',')
			)

	OPEN ID

	FETCH NEXT FROM ID INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_PERSONAL', @ID, @OLD OUTPUT

		DELETE FROM	Income.IncomePersonal
		WHERE IP_ID = @ID

		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_PERSONAL', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'INCOME_PERSONAL', '��������', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID


END
GRANT EXECUTE ON [Income].[INCOME_PERSONAL_DELETE] TO rl_income_personal;
GO