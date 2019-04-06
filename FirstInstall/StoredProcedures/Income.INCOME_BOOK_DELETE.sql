USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Income].[INCOME_BOOK_DELETE]
	@IB_ID	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ID UNIQUEIDENTIFIER

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)


	DECLARE ID CURSOR LOCAL FOR
		SELECT	IB_ID
		FROM	Income.IncomeBook
		WHERE	IB_ID_MASTER	IN
			(
				SELECT ID
				FROM Common.TableFromList(@IB_ID, ',')
			)

	OPEN ID
	
	FETCH NEXT FROM ID INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_BOOK', @ID, @OLD OUTPUT

		DELETE FROM	Income.IncomeBook
		WHERE IB_ID = @ID

		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_BOOK', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'INCOME_BOOK', '��������', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID



	DECLARE ID CURSOR LOCAL FOR
		SELECT	IB_ID
		FROM	Income.IncomeBook
		WHERE	IB_ID	IN
			(
				SELECT ID
				FROM Common.TableFromList(@IB_ID, ',')
			)
	OPEN ID
	
	FETCH NEXT FROM ID INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_BOOK', @ID, @OLD OUTPUT

		DELETE FROM	Income.IncomeBook
		WHERE IB_ID = @ID

		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_BOOK', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'INCOME_BOOK', '��������', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID

END
