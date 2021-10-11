USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Memo].[KGS_MEMO_DELETE]
	@ID	UNIQUEIDENTIFIER
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

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO Memo.KGSMemo(ID_MASTER, NAME, DATE, PRICE, ID_MONTH, MON_CNT, STATUS, UPD_DATE, UPD_USER)
				OUTPUT inserted.ID INTO @TBL
				SELECT @ID, NAME, DATE, PRICE, ID_MONTH, MON_CNT, 2, UPD_DATE, UPD_USER
				FROM Memo.KGSMemo
				WHERE ID = @ID

		DECLARE @OLD_ID UNIQUEIDENTIFIER

		SELECT @OLD_ID = ID
		FROM @TBL

		UPDATE Memo.KGSMemo
		SET STATUS = 3,
			UPD_DATE	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID

		INSERT INTO Memo.KGSMemoClient(ID_MEMO, ID_CLIENT, NAME, ADDRESS, NUM)
			SELECT @OLD_ID, ID_CLIENT, NAME, ADDRESS, NUM
			FROM Memo.KGSMemoClient
			WHERE ID_MEMO = @ID

		INSERT INTO Memo.KGSMemoDistr(ID_MEMO, ID_CLIENT, ID_SYSTEM, DISTR, COMP, ID_NET, ID_TYPE, DISCOUNT, INFLATION, MON_CNT, PRICE, TAX_PRICE, TOTAL_PRICE, CURVED, TOTAL_PERIOD)
			SELECT @OLD_ID, ID_CLIENT, ID_SYSTEM, DISTR, COMP, ID_NET, ID_TYPE, DISCOUNT, INFLATION, MON_CNT, PRICE, TAX_PRICE, TOTAL_PRICE, CURVED, TOTAL_PERIOD
			FROM Memo.KGSMemoDistr
			WHERE ID_MEMO = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[KGS_MEMO_DELETE] TO rl_kgs_complect_calc;
GO
