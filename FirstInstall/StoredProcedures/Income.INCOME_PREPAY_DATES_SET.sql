USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Income].[INCOME_PREPAY_DATES_SET]
	@ID_ID		VARCHAR(MAX),
	@PREPAY		BIT,
	@CON_DATE	SMALLDATETIME,
	@DATE		SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	IF @PREPAY = 1
	BEGIN
		SET @CON_DATE = NULL
		SET @DATE = NULL
	END

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
		SET		ID_PREPAY		=	@PREPAY,
				ID_SUP_CONTRACT	=	@CON_DATE,
				ID_SUP_DATE		=	@DATE				
		WHERE	ID_ID	= @ID

		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_DETAIL', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'INCOME_DETAIL', '�������� ���������� � ���', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID

END
