USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CONTRACT_EXPECTED_NUM]
	@DATE		SMALLDATETIME,
	@VENDOR		UNIQUEIDENTIFIER,
	@NUM		INT,
	@COUNT		INT,
	@TYPE		UNIQUEIDENTIFIER,
	@ID_YEAR	UNIQUEIDENTIFIER,
	@NUM_S		NVARCHAR(128) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @YEAR INT
	
	SELECT @YEAR = DATEPART(YEAR, START)
	FROM Common.Period
	WHERE ID = @ID_YEAR

	IF ISNULL(@COUNT, 1) = 1
	BEGIN
		IF @NUM IS NULL
			SELECT @NUM = ISNULL(
												(
													SELECT MAX(NUM) 
													FROM 
														Contract.Contract a
														INNER JOIN Common.Period b ON a.ID_YEAR = b.ID
													WHERE ID_VENDOR = @VENDOR 
														AND DATEPART(YEAR, START) = @YEAR
												) + 1, 
												1)
			FROM Contract.Type
			WHERE ID = @TYPE
			
		SELECT @NUM_S = CONVERT(NVARCHAR(16), @YEAR) + '-' + PREFIX + ' ' + REPLICATE('0', 4 - LEN(CONVERT(NVARCHAR(16), @NUM))) + CONVERT(NVARCHAR(32), @NUM)
		FROM Contract.Type
		WHERE ID = @TYPE
	END
	ELSE
	BEGIN
		IF @NUM IS NULL
			SELECT @NUM_S = CONVERT(NVARCHAR(16), @YEAR) + '-' + 
							PREFIX + ' ' + 
								CONVERT(NVARCHAR(32), 
										ISNULL(
												(
													SELECT MAX(NUM) 
													FROM 
														Contract.Contract a
														INNER JOIN Common.Period b ON a.ID_YEAR = b.ID
													WHERE ID_VENDOR = @VENDOR 
														AND DATEPART(YEAR, START) = @YEAR
												) + 1, 
												1))
							+ ' -- ' +
							CONVERT(NVARCHAR(16), @YEAR) + '-' + PREFIX + ' ' + 
								CONVERT(NVARCHAR(32), 
										ISNULL(
												(
													SELECT MAX(NUM) 
													FROM 
														Contract.Contract a
														INNER JOIN Common.Period b ON a.ID_YEAR = b.ID
													WHERE ID_VENDOR = @VENDOR 
														AND DATEPART(YEAR, START) = @YEAR
												) + 1, 
												1) + @COUNT - 1)
			FROM Contract.Type
			WHERE ID = @TYPE
		ELSE
			SELECT @NUM_S = CONVERT(NVARCHAR(16), @YEAR) + '-' + PREFIX + ' ' + CONVERT(NVARCHAR(32), @NUM) + ' -- ' + CONVERT(NVARCHAR(16), @YEAR) + '-' + PREFIX + ' ' + CONVERT(NVARCHAR(32), @NUM + @COUNT - 1)
			FROM Contract.Type
			WHERE ID = @TYPE
	END
END
