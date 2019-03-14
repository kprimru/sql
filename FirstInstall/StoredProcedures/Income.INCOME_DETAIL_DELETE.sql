USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
CREATE PROCEDURE [Income].[INCOME_DETAIL_DELETE]
	@ID_ID	VARCHAR(MAX)
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



	DECLARE ID CURSOR LOCAL FOR
		SELECT	ID_ID
		FROM	Income.IncomeDetail
		WHERE	ID_ID	IN
			(
				SELECT ID
				FROM Common.TableFromList(@ID_ID, ',')
			)
	OPEN ID
	
	DECLARE @IND_ID VARCHAR(MAX)	

	FETCH NEXT FROM ID INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_DETAIL', @ID, @OLD OUTPUT
		
		SET @IND_ID = ''

		SELECT @IND_ID = @IND_ID + CONVERT(VARCHAR(50), IND_ID) + ','
		FROM Install.InstallDetail
		WHERE IND_ID_INCOME = @ID

		IF @IND_ID <> '' 
			SET @IND_ID = LEFT(@IND_ID, LEN(@IND_ID) - 1)

		EXEC Install.INSTALL_DETAIL_DELETE @IND_ID

		DELETE FROM	Income.IncomeDetail
		WHERE ID_ID = @ID
		
		SET @IND_ID = ''		
		
		EXEC Common.PROTOCOL_VALUE_GET 'INCOME_DETAIL', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'INCOME_DETAIL', '��������', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID	
END

