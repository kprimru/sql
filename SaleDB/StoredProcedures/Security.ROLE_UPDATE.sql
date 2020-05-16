USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ROLE_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@MASTER		UNIQUEIDENTIFIER,
	@NAME		NVARCHAR(128),
	@CAPTION	NVARCHAR(256),
	@NOTE		NVARCHAR(MAX)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		BEGIN TRAN role_update

		DECLARE @OLD_NAME	NVARCHAR(128)

		SELECT @OLD_NAME = NAME
		FROM Security.Roles
		WHERE ID = @ID

		IF (ISNULL(@OLD_NAME, N'') = N'') AND ISNULL(@NAME, N'') <> N''
		BEGIN
			EXEC ('CREATE ROLE [' + @NAME + ']')
		END
		ELSE IF (ISNULL(@OLD_NAME, N'') <> N'') AND ISNULL(@NAME, N'') = N''
		BEGIN
			EXEC ('DROP ROLE [' + @NAME + ']')
		END
		ELSE IF (ISNULL(@OLD_NAME, N'') <> N'') AND (ISNULL(@NAME, N'') <> N'') AND (@OLD_NAME <> @NAME)
		BEGIN
			EXEC ('ALTER ROLE [' + @OLD_NAME + '] WITH NAME = [' + @NAME + ']')
		END

		UPDATE Security.Roles
		SET MASTER = @MASTER,
			NAME = @NAME,
			CAPTION = @CAPTION,
			NOTE = @NOTE,
			LAST = GETDATE()
		WHERE ID = @ID

		COMMIT TRAN role_update
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN role_update

		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLE_UPDATE] TO rl_role_w;
GO