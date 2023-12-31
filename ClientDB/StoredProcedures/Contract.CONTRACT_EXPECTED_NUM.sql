USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[CONTRACT_EXPECTED_NUM]
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

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		-- ���� ������������ ������� ��� � �������� ������� - �� � ������ ������ �� �����
		IF @NUM_S IS NOT NULL
			RETURN;

		DECLARE @YEAR INT

		SELECT @YEAR = DATEPART(YEAR, START)
		FROM Common.Period
		WHERE ID = @ID_YEAR

		IF ISNULL(@COUNT, 1) = 1
		BEGIN
			IF @NUM IS NULL BEGIN
			    /*
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
				*/
				SELECT TOP (1) @NUM = N.ID
				FROM dbo.Numbers AS N
				LEFT JOIN Contract.Contract AS C ON C.NUM = N.ID AND C.ID_VENDOR = @VENDOR AND C.ID_YEAR = @ID_YEAR
				WHERE C.ID IS NULL
				ORDER BY N.ID;
			END;

			SELECT @NUM_S = CONVERT(NVARCHAR(16), @YEAR) + '-' + CASE WHEN PREFIX = '' THEN '' ELSE PREFIX + ' ' END + REPLICATE('0', 4 - LEN(CONVERT(NVARCHAR(16), @NUM))) + CONVERT(NVARCHAR(32), @NUM)
			FROM Contract.Type
			WHERE ID = @TYPE
		END
		ELSE
		BEGIN
		    -- ToDo ������� ��������� � ����������� ���������
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CONTRACT_EXPECTED_NUM] TO rl_contract_register_r;
GO
