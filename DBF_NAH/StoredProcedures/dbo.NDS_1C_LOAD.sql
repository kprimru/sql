USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[NDS_1C_LOAD]
	@ORG	SMALLINT,
	@TAX	SMALLINT,
	@PERIOD	SMALLINT,
	@DATA	NVARCHAR(MAX)
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

		DECLARE @ID	UNIQUEIDENTIFIER

		SELECT @ID = ID
		FROM dbo.NDS1C
		WHERE ID_ORG = @ORG
			AND ID_TAX = @TAX
			AND ID_PERIOD = @PERIOD

		IF @ID IS NULL
			SET @ID = NEWID()

		DELETE FROM dbo.NDS1CDetail WHERE ID_MASTER = @ID
		DELETE FROM dbo.NDS1C WHERE ID = @ID

		INSERT INTO dbo.NDS1C(ID, ID_ORG, ID_TAX, ID_PERIOD)
			VALUES(@ID, @ORG, @TAX, @PERIOD)

		DECLARE @XML XML

		SET @XML = CAST(@DATA AS XML)

		IF OBJECT_ID('tempdb..#nds') IS NOT NULL
			DROP TABLE #nds

		CREATE TABLE #nds
			(
				CLIENT	NVARCHAR(256),
				TP		NVARCHAR(64),
				P1S		NVARCHAR(64),
				P2S		NVARCHAR(64),
				P1		MONEY,
				P2		MONEY
			)

		INSERT INTO #nds(CLIENT, TP, P1S, P2S)
			SELECT
				c.value('@cl', 'NVARCHAR(256)'),
				c.value('@tp', 'NVARCHAR(64)'),
				c.value('@p1', 'NVARCHAR(64)'),
				c.value('@p2', 'NVARCHAR(64)')
			FROM
				@XML.nodes('/root/item') AS a(c)

		UPDATE #nds
		SET P1S = LTRIM(RTRIM(P1S)),
			P2S = LTRIM(RTRIM(P2S))

		UPDATE #nds
		SET P1S = CASE P1S WHEN '' THEN NULL ELSE P1S END,
			P2S = CASE P2S WHEN '' THEN NULL ELSE P2S END

		UPDATE #nds
		SET P1S = REPLACE(P1S, ',', '.'),
			P2S = REPLACE(P2S, ',', '.')

		UPDATE #nds
		SET P1S = REPLACE(P1S, ' ', ''),
			P2S = REPLACE(P2S, ' ', '')

		UPDATE #nds
		SET CLIENT = REPLACE(CLIENT, '''', '"')

		UPDATE #nds
		SET P1 = P1S,
			P2 = P2S

		INSERT INTO dbo.NDS1CDetail(ID_MASTER, CLIENT, TP, PRICE, PRICE2)
			SELECT @ID, CLIENT, LTRIM(RTRIM(TP)), P1, P2
			FROM #nds

		IF OBJECT_ID('tempdb..#nds') IS NOT NULL
			DROP TABLE #nds

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[NDS_1C_LOAD] TO rl_book_sale_p;
GO