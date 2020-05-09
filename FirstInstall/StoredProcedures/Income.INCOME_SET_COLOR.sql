USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Income].[INCOME_SET_COLOR]
	@ID_ID	VARCHAR(MAX),
	@COLOR	INT
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
		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_DETAIL', @ID, @OLD OUTPUT

		UPDATE	Income.IncomeDetail
		SET		ID_COLOR	= @COLOR
		WHERE	ID_ID	= @ID

		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_DETAIL', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'INCOME_DETAIL', '��������� �����', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID
END
GO
GRANT EXECUTE ON [Income].[INCOME_SET_COLOR] TO rl_income_w;
GO