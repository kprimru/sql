USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PROTOCOL_SEARCH]
	@USERS VARCHAR(MAX),
	@OPER VARCHAR(MAX),
	@BEGIN DATETIME,
	@END DATETIME,
	@CLIENT	INT,
	@TXT VARCHAR(100)
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

		SET @TXT = NULLIF(@TXT, '%%')
		SET @USERS = NULLIF(@USERS, '')
		SET @OPER = NULLIF(@OPER, '')

		DECLARE @toper TABLE
			(
				OP_NAME VARCHAR(128) PRIMARY KEY CLUSTERED
			)

		DECLARE @tusers TABLE
			(
				US_NAME NVARCHAR(128) PRIMARY KEY CLUSTERED
			)

		IF @USERS IS NOT NULL
			INSERT INTO @tusers
				SELECT *
				FROM dbo.GET_STRING_TABLE_FROM_LIST(@USERS, ',')

		IF @OPER IS NOT NULL
			INSERT INTO @toper
				SELECT *
				FROM dbo.GET_STRING_TABLE_FROM_LIST(@OPER, ',')

		SELECT CL_ID, CL_PSEDO, ID_DOCUMENT, TP, OPER, TXT, USR_NAME, UPD_DATE
		FROM
			dbo.FinancingProtocol
			LEFT OUTER JOIN dbo.ClientTable ON CL_ID = ID_CLIENT
		WHERE (UPD_DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (UPD_DATE <= @END OR @END IS NULL)
			AND (ID_CLIENT = @CLIENT OR @CLIENT IS NULL)
			AND (TXT LIKE @TXT OR @TXT IS NULL)
			AND (@USERS IS NULL OR USR_NAME IN (SELECT US_NAME FROM @tusers))
			AND (@OPER IS NULL OR OPER IN (SELECT OP_NAME FROM @toper))
		ORDER BY UPD_DATE DESC, ID
		OPTION (RECOMPILE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PROTOCOL_SEARCH] TO rl_financing_protocol_r;
GO
