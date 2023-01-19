USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[ROLE_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[ROLE_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[ROLE_DELETE]
	@ID	UNIQUEIDENTIFIER
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
		BEGIN TRAN role_delete

		IF EXISTS
			(
				SELECT *
				FROM Security.Roles
				WHERE MASTER = @ID
			)
		BEGIN
			DECLARE @SUB	UNIQUEIDENTIFIER
			DECLARE RL CURSOR LOCAL FOR
				SELECT ID FROM Security.Roles WHERE MASTER = @ID

			OPEN RL

			FETCH NEXT FROM RL INTO @SUB

			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC Security.ROLE_DELETE @SUB

				FETCH NEXT FROM RL INTO @SUB
			END

			CLOSE RL
			DEALLOCATE RL
		END

		DECLARE @NAME NVARCHAR(128)

		SELECT @NAME = NAME
		FROM Security.Roles
		WHERE ID = @ID

		DELETE FROM Security.Roles
		WHERE ID = @ID

		IF ISNULL(@NAME, N'') <> N''
			EXEC ('DROP ROLE [' + @NAME + ']')

		COMMIT TRAN role_delete
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN role_delete

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
GRANT EXECUTE ON [Security].[ROLE_DELETE] TO rl_role_d;
GO
