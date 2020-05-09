USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[CONTRACT_SELECT]
	@START			SMALLDATETIME,
	@FINISH			SMALLDATETIME,
	@VENDOR			UNIQUEIDENTIFIER,
	@TYPE			UNIQUEIDENTIFIER,
	@SPECIFICATION	UNIQUEIDENTIFIER,
	@NUM			VarChar(100),
	@CLIENT			NVARCHAR(256),
	@SPEC_SHOW		BIT = 1,
	@ADD_SHOW		BIT = 1,
	@LAW			NVARCHAR(128) = NULL,
	@CNT			INT = NULL OUTPUT
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



	DECLARE @contract TABLE
	(
		ID		UNIQUEIDENTIFIER PRIMARY KEY
	)

	DECLARE @ROWCOUNT INT

	DECLARE @Num_S	VarChar(100);
	DECLARE @Num_I	Int;

	BEGIN TRY
		IF @NUM = '' SET @NUM = NULL;



		IF @NUM IS NOT NULL BEGIN
			IF ISNUMERIC(@NUM) = 1
				SET @Num_I = Cast(@Num AS Int)

			SET @Num_S = @Num;
		END

		/*
		IF @START IS NULL AND @FINISH IS NULL AND @VENDOR IS NULL AND @TYPE IS NULL AND @SPECIFICATION IS NULL AND @NUM IS NULL AND @CLIENT IS NULL
			SET @ROWCOUNT = 200
		ELSE
			SET @ROWCOUNT = 10000000
		*/
		SET @ROWCOUNT = 200

		INSERT INTO @contract(ID)
			SELECT TOP (@ROWCOUNT) ID
			FROM Contract.Contract a
			WHERE STATUS = 1
				AND (DATE >= @START OR @START IS NULL)
				AND (DATE <= @FINISH OR @FINISH IS NULL)
				AND (ID_VENDOR = @VENDOR OR @VENDOR IS NULL)
				AND (CLIENT LIKE @CLIENT OR @CLIENT IS NULL)
				AND (NUM = @Num_I AND @Num_I IS NOT NULL OR NUM_S LIKE '%' + Cast(@Num_S AS VarChar(20)) + '%' OR @NUM IS NULL)
				AND (ID_TYPE = @TYPE OR @TYPE IS NULL)
				AND (LAW LIKE @LAW OR @LAW IS NULL)
				AND (
						@SPECIFICATION IS NULL OR
						EXISTS
							(
								SELECT *
								FROM Contract.ContractSpecification z
								WHERE z.ID_CONTRACT = a.ID
									AND z.ID_SPECIFICATION = @SPECIFICATION
							)
					)
			ORDER BY DATE DESC, NUM DESC

		SET @CNT = (SELECT COUNT(*) FROM @contract)

		SELECT b.ID, NULL AS ID_MASTER, b.NUM, b.NUM_S, c.NAME, d.IND, DATE, b.NOTE, CLIENT, RETURN_DATE, UPD_DATE, UPD_USER, d.NAME AS ST_NAME, b.UPD_USER, LAW
		FROM @contract a
		INNER JOIN Contract.Contract b ON a.ID = b.ID
		INNER JOIN Contract.Type c ON b.ID_TYPE = c.ID
		INNER JOIN Contract.Status d ON b.ID_STATUS = d.ID

		UNION ALL

		SELECT b.ID, a.ID, b.NUM, CONVERT(NVARCHAR(32), b.NUM), c.NAME, d.IND, DATE, b.NOTE, '', RETURN_DATE, NULL, b.UPD_USER, d.NAME AS ST_NAME, NULL, NULL
		FROM @contract a
		INNER JOIN Contract.ContractSpecification b ON a.ID = b.ID_CONTRACT
		INNER JOIN Contract.Specification c ON b.ID_SPECIFICATION = c.ID
		INNER JOIN Contract.Status d ON b.ID_STATUS = d.ID
		WHERE @SPEC_SHOW = 1

		UNION ALL

		SELECT b.ID, a.ID, b.NUM, CONVERT(NVARCHAR(32), b.NUM), 'Дополнительное соглашение', d.IND, REG_DATE, b.NOTE, '', RETURN_DATE, NULL, b.UPD_USER, d.NAME AS ST_NAME, NULL, NULL
		FROM @contract a
		INNER JOIN Contract.Additional b ON a.ID = b.ID_CONTRACT
		INNER JOIN Contract.Status d ON b.ID_STATUS = d.ID
		WHERE @ADD_SHOW = 1

		ORDER BY DATE DESC, NUM DESC
		OPTION(RECOMPILE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[CONTRACT_SELECT] TO rl_contract_register_r;
GO