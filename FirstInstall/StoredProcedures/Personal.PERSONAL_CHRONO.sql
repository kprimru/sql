﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PERSONAL_CHRONO]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Personal].[PERSONAL_CHRONO]  AS SELECT 1')
GO
ALTER PROCEDURE [Personal].[PERSONAL_CHRONO]
	@PER_ID_DEP		UNIQUEIDENTIFIER,
	@PER_NAME		VARCHAR(150),
	@PER_EMAIL		VARCHAR(256),
	@PER_ID_TYPE	UNIQUEIDENTIFIER,
	@PER_DATE		SMALLDATETIME,
	@PER_ID_MASTER	UNIQUEIDENTIFIER,
	@PER_END		SMALLDATETIME,
	@PER_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL', @PER_ID_MASTER, @OLD OUTPUT


	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER

	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Personal.PersonalDetail
		SET		PER_END	=	@PER_END,
				PER_REF	=	2
		WHERE	PER_ID	=	@PER_ID

		INSERT INTO
				Personal.PersonalDetail(
					PER_ID_MASTER,
					PER_ID_DEP,
					PER_NAME,
					PER_EMAIL,
					PER_ID_TYPE,
					PER_DATE
				)
		OUTPUT INSERTED.PER_ID INTO @TBL
		VALUES	(
					@PER_ID_MASTER,
					@PER_ID_DEP,
					@PER_NAME,
					@PER_EMAIL,
					@PER_ID_TYPE,
					@PER_DATE
				)

		SELECT	@PER_ID = ID
		FROM	@TBL
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION


	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL', @PER_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'PERSONAL', 'Хронологическое изменение', @PER_ID_MASTER, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Personal].[PERSONAL_CHRONO] TO rl_personal_u;
GO
