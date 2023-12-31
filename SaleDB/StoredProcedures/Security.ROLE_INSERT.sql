USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ROLE_INSERT]
	@MASTER		UNIQUEIDENTIFIER,
	@NAME		NVARCHAR(128),
	@CAPTION	NVARCHAR(256),
	@NOTE		NVARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
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

	DECLARE @TXT NVARCHAR(3000)

	IF EXISTS
		(
			SELECT * FROM sys.database_principals WHERE name = @NAME
		)
	BEGIN
		SET @TXT = '���� ��� ������������ "' + @NAME + '" ��� ����������. �������� ������ ��������.'

		RAISERROR(@TXT, 16, 1)

		RETURN
	END

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	BEGIN TRY
		BEGIN TRAN role_insert

		INSERT INTO Security.Roles(MASTER, NAME, CAPTION, NOTE)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@MASTER, @NAME, @CAPTION, @NOTE)

		SELECT @ID = ID FROM @TBL

		IF ISNULL(@NAME, N'') <> N''
			EXEC ('CREATE ROLE [' + @NAME + ']')

		COMMIT TRAN role_insert
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN role_insert

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
GRANT EXECUTE ON [Security].[ROLE_INSERT] TO rl_role_w;
GO
