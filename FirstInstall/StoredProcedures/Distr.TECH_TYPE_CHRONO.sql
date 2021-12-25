﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[TECH_TYPE_CHRONO]
	@TT_NAME		VARCHAR(50),
	@TT_SHORT		VARCHAR(50),
	@TT_REG			INT,
	@TT_COEF		DECIMAL(8, 4),
	@TT_DATE		SMALLDATETIME,
	@TT_ID_MASTER	UNIQUEIDENTIFIER,
	@TT_END			SMALLDATETIME,
	@TT_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'TECH_TYPE', @TT_ID_MASTER, @OLD OUTPUT


	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER


	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Distr.TechTypeDetail
		SET		TT_END	=	@TT_END,
				TT_REF	=	2
		WHERE	TT_ID	=	@TT_ID

		UPDATE	Distr.TechType
		SET		TTMS_LAST	=	GETDATE()
		WHERE	TTMS_ID		=	@TT_ID_MASTER

		INSERT INTO
				Distr.TechTypeDetail(
					TT_ID_MASTER,
					TT_NAME,
					TT_SHORT,
					TT_REG,
					TT_COEF,
					TT_DATE
				)
		OUTPUT INSERTED.TT_ID INTO @TBL
		VALUES	(
					@TT_ID_MASTER,
					@TT_NAME,
					@TT_SHORT,
					@TT_REG,
					@TT_COEF,
					@TT_DATE
				)

		SELECT	@TT_ID = ID
		FROM	@TBL
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION

	EXEC Common.PROTOCOL_VALUE_GET 'TECH_TYPE', @TT_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'TECH_TYPE', 'Хронологическое изменение', @TT_ID_MASTER, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Distr].[TECH_TYPE_CHRONO] TO rl_tech_type_u;
GO
