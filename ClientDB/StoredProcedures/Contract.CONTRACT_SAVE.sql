USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[CONTRACT_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[CONTRACT_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[CONTRACT_SAVE]
	@ID				UNIQUEIDENTIFIER OUTPUT,
	@NUM			INT,
	@NUM_FIXED		NVARCHAR(64),
	@COUNT			INT,
	@TYPE			UNIQUEIDENTIFIER,
	@VENDOR			UNIQUEIDENTIFIER,
	@DATE			SMALLDATETIME,
	@NOTE			NVARCHAR(MAX),
	@ID_YEAR		UNIQUEIDENTIFIER,
	@ID_CLIENT		INT,
	@CLIENT			NVARCHAR(512),
	@SPECIFICATION	NVARCHAR(MAX),
	@ADDITIONAL		NVARCHAR(MAX),
	@LAW			NVARCHAR(MAX) = NULL
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

		DECLARE @NUM_S NVARCHAR(64)

		DECLARE @DEF_STATUS	UNIQUEIDENTIFIER

		DECLARE @XML XML

		SELECT @DEF_STATUS = ID
		FROM Contract.Status
		WHERE ORD = 1

		DECLARE @YEAR INT

		SELECT @YEAR = DATEPART(YEAR, START)
		FROM Common.Period
		WHERE ID = @ID_YEAR

		SELECT @DEF_STATUS

		IF @NUM_FIXED IS NOT NULL
			SET @NUM_S = @NUM_FIXED
		ELSE BEGIN
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
			    */
			    SELECT TOP (1) @NUM = N.ID
				FROM dbo.Numbers AS N
				LEFT JOIN Contract.Contract AS C ON C.NUM = N.ID AND C.ID_VENDOR = @VENDOR AND C.ID_YEAR = @ID_YEAR
				WHERE C.ID IS NULL
				ORDER BY N.ID;
			END;

			SELECT @NUM_S = CONVERT(NVARCHAR(16), @YEAR) + '-' + CASE WHEN PREFIX = '' THEN '' ELSE PREFIX + ' ' END + REPLICATE('0', 4 - LEN(CONVERT(NVARCHAR(16), @NUM))) + CONVERT(NVARCHAR(16), @NUM)
			FROM Contract.Type
			WHERE ID = @TYPE
		END;

		IF @ID IS NULL
		BEGIN
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)



			INSERT INTO Contract.Contract(NUM, NUM_S, ID_TYPE, ID_VENDOR, REG_DATE, DATE, ID_YEAR, NOTE, ID_CLIENT, CLIENT, ID_STATUS, LAW)
				OUTPUT inserted.ID INTO @TBL
				SELECT @NUM, @NUM_S, @TYPE, @VENDOR, @DATE, @DATE, @ID_YEAR, @NOTE, @ID_CLIENT, @CLIENT, @DEF_STATUS, @LAW

			SELECT @ID = ID FROM @TBL

			INSERT INTO Contract.DocumentHistory(ID_DOCUMENT, ID_STATUS)
				SELECT @ID, @DEF_STATUS

			DELETE FROM @TBL

			SET @XML = CAST(@SPECIFICATION AS XML)

			INSERT INTO Contract.ContractSpecification(ID_CONTRACT, ID_SPECIFICATION, NUM, DATE, REG_DATE, FINISH_DATE, RETURN_DATE, ID_STATUS, NOTE)
				OUTPUT inserted.ID INTO @TBL
				SELECT @ID, ID_SPECIFICATION, NUM, DATE, DATE, FINISH_DATE, RETURN_DATE, @DEF_STATUS, NOTE
				FROM
					(
						SELECT
							c.value('@id_spec[1]', 'UNIQUEIDENTIFIER') AS ID_SPECIFICATION,
							c.value('@num[1]', 'INT') AS NUM,
							CONVERT(SMALLDATETIME, c.value('@date[1]', 'NVARCHAR(64)'), 112) AS DATE,
							CONVERT(SMALLDATETIME, c.value('@finish_date[1]', 'NVARCHAR(64)'), 112) AS FINISH_DATE,
							CONVERT(SMALLDATETIME, c.value('@return_date[1]', 'NVARCHAR(64)'), 112) AS RETURN_DATE,
							c.value('(.)[1]', 'NVARCHAR(MAX)') AS NOTE
						FROM @xml.nodes('/root/item') AS a(c)
					) AS o_O

			INSERT INTO Contract.DocumentHistory(ID_DOCUMENT, ID_STATUS)
				SELECT ID, @DEF_STATUS
				FROM @TBL

			DELETE FROM @TBL

			SET @XML = CAST(@ADDITIONAL AS XML)

			INSERT INTO Contract.Additional(ID_CONTRACT, NUM, REG_DATE, ID_STATUS, NOTE)
				OUTPUT inserted.ID INTO @TBL
				SELECT @ID, NUM, DATE, @DEF_STATUS, NOTE
				FROM
					(
						SELECT
							c.value('@num[1]', 'INT') AS NUM,
							CONVERT(SMALLDATETIME, c.value('@date[1]', 'NVARCHAR(64)'), 112) AS DATE,
							c.value('(.)[1]', 'NVARCHAR(MAX)') AS NOTE
						FROM @xml.nodes('/root/item') AS a(c)
					) AS o_O

			INSERT INTO Contract.DocumentHistory(ID_DOCUMENT, ID_STATUS)
				SELECT ID, @DEF_STATUS
				FROM @TBL
		END
		ELSE
		BEGIN
			UPDATE Contract.Contract
			SET	NUM			=	@NUM,
				NUM_S		=	@NUM_S,
				ID_TYPE		=	@TYPE,
				ID_VENDOR	=	@VENDOR,
				REG_DATE	=	@DATE,
				ID_YEAR		=	@ID_YEAR,
				NOTE		=	@NOTE,
				ID_CLIENT	=	@ID_CLIENT,
				CLIENT		=	@CLIENT,
				LAW			=	@LAW
			WHERE ID = @ID

			DELETE FROM @TBL

			SET @XML = CAST(@SPECIFICATION AS XML)

			DELETE FROM Contract.ContractSpecification
			WHERE ID_CONTRACT = @ID
				AND SignDate IS NULL
				AND
					ID NOT IN
					(
						SELECT c.value('@id[1]', 'UNIQUEIDENTIFIER')
						FROM @xml.nodes('/root/item') AS a(c)
					)

			UPDATE a
			SET a.ID_SPECIFICATION = b.ID_SPECIFICATION,
				a.NUM = b.NUM,
				a.REG_DATE = b.DATE,
				a.DATE = b.DATE,
				a.NOTE = b.NOTE,
				a.FINISH_DATE = b.FINISH_DATE,
				a.RETURN_DATe = b.RETURN_DATE
			FROM
				Contract.ContractSpecification a
				INNER JOIN
					(
						SELECT
							c.value('@id[1]', 'UNIQUEIDENTIFIER') AS ID,
							c.value('@id_spec[1]', 'UNIQUEIDENTIFIER') AS ID_SPECIFICATION,
							c.value('@num[1]', 'INT') AS NUM,
							CONVERT(SMALLDATETIME, c.value('@date[1]', 'NVARCHAR(64)'), 112) AS DATE,
							CONVERT(SMALLDATETIME, c.value('@finish_date[1]', 'NVARCHAR(64)'), 112) AS FINISH_DATE,
							CONVERT(SMALLDATETIME, c.value('@return_date[1]', 'NVARCHAR(64)'), 112) AS RETURN_DATE,
							c.value('(.)[1]', 'NVARCHAR(MAX)') AS NOTE
						FROM @xml.nodes('/root/item') AS a(c)
						--WHERE c.value('@id[1]', 'UNIQUEIDENTIFIER') IS NULL
					) AS b ON a.ID = b.ID
				INNER JOIN Contract.Status c ON c.ID = a.ID_STATUS
			WHERE c.ORD = 1

			INSERT INTO Contract.ContractSpecification(ID_CONTRACT, ID_SPECIFICATION, NUM, REG_DATE, DATE, FINISH_DATE, RETURN_DATE, ID_STATUS, NOTE)
				OUTPUT inserted.ID INTO @TBL
				SELECT @ID, ID_SPECIFICATION, NUM, DATE, DATE, FINISH_DATE, RETURN_DATE, @DEF_STATUS, NOTE
				FROM
					(
						SELECT
							c.value('@id_spec[1]', 'UNIQUEIDENTIFIER') AS ID_SPECIFICATION,
							c.value('@num[1]', 'INT') AS NUM,
							CONVERT(SMALLDATETIME, c.value('@date[1]', 'NVARCHAR(64)'), 112) AS DATE,
							CONVERT(SMALLDATETIME, c.value('@finish_date[1]', 'NVARCHAR(64)'), 112) AS FINISH_DATE,
							CONVERT(SMALLDATETIME, c.value('@return_date[1]', 'NVARCHAR(64)'), 112) AS RETURN_DATE,
							c.value('(.)[1]', 'NVARCHAR(MAX)') AS NOTE
						FROM @xml.nodes('/root/item') AS a(c)
						WHERE c.value('@id[1]', 'UNIQUEIDENTIFIER') IS NULL
					) AS o_O

			INSERT INTO Contract.DocumentHistory(ID_DOCUMENT, ID_STATUS)
				SELECT ID, @DEF_STATUS
				FROM @TBL

			DELETE FROM @TBL

			SET @XML = CAST(@ADDITIONAL AS XML)

			DELETE FROM Contract.Additional
			WHERE ID_CONTRACT = @ID
				AND SignDate IS NULL
				AND ID NOT IN
				(
					SELECT c.value('@id[1]', 'UNIQUEIDENTIFIER')
					FROM @xml.nodes('/root/item') AS a(c)
				)

			INSERT INTO Contract.Additional(ID_CONTRACT, NUM, REG_DATE, ID_STATUS, NOTE)
				OUTPUT inserted.ID INTO @TBL
				SELECT @ID, NUM, DATE, @DEF_STATUS, NOTE
				FROM
					(
						SELECT
							c.value('@num[1]', 'INT') AS NUM,
							CONVERT(SMALLDATETIME, c.value('@date[1]', 'NVARCHAR(64)'), 112) AS DATE,
							c.value('(.)[1]', 'NVARCHAR(MAX)') AS NOTE
						FROM @xml.nodes('/root/item') AS a(c)
						WHERE c.value('@id[1]', 'UNIQUEIDENTIFIER') IS NULL
					) AS o_O

			UPDATE A
			SET NOTE = X.Note
			FROM Contract.Additional A
			INNER JOIN
			(
				SELECT
					[Id] = c.value('@id[1]', 'UNIQUEIDENTIFIER'),
					[Note] = c.value('(.)[1]', 'NVARCHAR(MAX)')
				FROM @xml.nodes('/root/item') AS a(c)
				WHERE c.value('@id[1]', 'UNIQUEIDENTIFIER') IS NOT NULL
			) AS X ON A.Id = X.Id

			INSERT INTO Contract.DocumentHistory(ID_DOCUMENT, ID_STATUS)
				SELECT ID, @DEF_STATUS
				FROM @TBL
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
GRANT EXECUTE ON [Contract].[CONTRACT_SAVE] TO rl_contract_register_w;
GO
