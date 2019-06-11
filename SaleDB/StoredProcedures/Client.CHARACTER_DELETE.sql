USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[CHARACTER_DELETE]
	@ID		UNIQUEIDENTIFIER,
	@NEW_ID	UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY
		DECLARE @RN	BIGINT

		SELECT @RN = RN
		FROM 
			(
				SELECT ID, ROW_NUMBER() OVER(ORDER BY NAME) AS RN
				FROM Client.Character
			) AS o_O
		WHERE ID = @ID

		SELECT TOP 1 @NEW_ID = ID
		FROM	
			(
				SELECT ID, ROW_NUMBER() OVER(ORDER BY NAME) AS RN
				FROM Client.Character
			) AS o_O
		WHERE ID <> @ID 
			AND RN IN 
				(
					SELECT @RN + 1
					UNION ALL
					SELECT @RN - 1
				)

		DELETE
		FROM	Client.Character
		WHERE	ID		=	@ID
	END TRY
	BEGIN CATCH
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