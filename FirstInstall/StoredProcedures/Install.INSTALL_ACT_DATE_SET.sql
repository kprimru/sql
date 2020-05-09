USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Install].[INSTALL_ACT_DATE_SET]
	@IND_ID		VARCHAR(MAX),
	@ACT_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	DECLARE @ID		UNIQUEIDENTIFIER

	DECLARE ID CURSOR LOCAL FOR
		SELECT ID
		FROM Common.TableFromList(@IND_ID, ',')

	OPEN ID

	FETCH NEXT FROM ID INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_DETAIL', @ID, @OLD OUTPUT

		UPDATE	Install.InstallDetail
		SET		IND_ACT_DATE		=	@ACT_DATE
		WHERE	IND_ID	=	@ID

		EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_DETAIL', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'INSTALL_DETAIL', '���� �����', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID
END
GO
GRANT EXECUTE ON [Install].[INSTALL_ACT_DATE_SET] TO rl_install_act;
GO