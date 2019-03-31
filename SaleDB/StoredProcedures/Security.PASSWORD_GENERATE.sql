USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Security].[PASSWORD_GENERATE]
	@MODE	TINYINT = 1
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY
		IF @MODE = 3
			SELECT 
				ONE, TWO, THREE,
				LEFT(ONE, 3) + LEFT(TWO, 3) + LEFT(THREE, 3) AS SHORT
			FROM
				(
					SELECT
						(
							SELECT TOP 1 NAME
							FROM Common.Words		
							WHERE TYPE = 1
							ORDER BY NEWID()
						) AS ONE,
						(
							SELECT TOP 1 NAME
							FROM Common.Words		
							WHERE TYPE = 2
							ORDER BY NEWID()
						) AS TWO,
						(
							SELECT TOP 1 NAME
							FROM Common.Words		
							WHERE TYPE = 3
							ORDER BY NEWID()
						) AS THREE
				) AS o_O
		ELSE IF @MODE = 2
			SELECT 
				ONE, TWO,
				LEFT(ONE, 3) + LEFT(TWO, 3) AS SHORT
			FROM
				(
					SELECT
					(
						SELECT TOP 1 NAME
						FROM Common.Words		
						WHERE TYPE = 4
						ORDER BY NEWID()
					) AS ONE,
					(
						SELECT TOP 1 NAME
						FROM Common.Words		
						WHERE TYPE = 1
						ORDER BY NEWID()
					) AS TWO
			) AS o_O
		ELSE IF @MODE = 1
			SELECT 
				ONE AS SHORT 
			FROM
				(
					SELECT				
						(
							SELECT TOP 1 NAME
							FROM Common.Words		
							WHERE TYPE = 1
							ORDER BY NEWID()
						) AS ONE
				) AS o_O
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