USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[=CLIENT_CONTRACT_SELECT]
	@CLIENT	INT,
	@ADD	BIT,
	@SPEC	BIT
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

		IF OBJECT_ID('tempdb..#contract') IS NOT NULL
			DROP TABLE #contract

		CREATE TABLE #contract(ID UNIQUEIDENTIFIER PRIMARY KEY)

		INSERT INTO #contract(ID)
			SELECT DISTINCT ID_CONTRACT
			FROM
				Contract.ClientContract a
			WHERE a.ID_CLIENT = @CLIENT

		SELECT b.ID, c.NAME, b.NUM_S, b.DATE, b.NOTE
		FROM
			#contract a
			INNER JOIN Contract.Contract b ON a.ID = b.ID
			INNER JOIN dbo.Vendor c ON c.ID = b.ID_VENDOR


		IF OBJECT_ID('tempdb..#contract') IS NOT NULL
			DROP TABLE #contract

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[=CLIENT_CONTRACT_SELECT] TO rl_client_contract_r;
GO