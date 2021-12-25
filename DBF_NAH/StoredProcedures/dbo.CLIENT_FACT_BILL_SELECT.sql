USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/
ALTER PROCEDURE [dbo].[CLIENT_FACT_BILL_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE @Bill Table
    (
        BFM_ID          BigInt,
        BFM_DATE        DateTime,
        BFM_NUM         VarChar(50),
        BFM_ID_PERIOD   SmallInt,
        BILL_DATE       SmallDateTime,
        ORG_ID          SmallInt
        PRIMARY KEY CLUSTERED (BFM_ID)
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

	    INSERT INTO @Bill
	    SELECT
	        BFM_ID,
			BFM_DATE,
			BFM_NUM,
			BFM_ID_PERIOD,
			BILL_DATE,
			ORG_ID
		FROM dbo.BillFactMasterTable a
		WHERE CL_ID = @clientid;

		SELECT
			BFM_ID,
			BFM_DATE,
			(
				SELECT SUM(BD_TOTAL_UNPAY)
				FROM dbo.BillFactDetailTable
				WHERE BFD_ID_BFM = BFM_ID
			) AS BD_TOTAL_PRICE,
			BFM_NUM, BFM_ID_PERIOD, BILL_DATE, ORG_PSEDO
		FROM @Bill a
		INNER MERGE JOIN dbo.OrganizationTable b ON a.ORG_ID = b.ORG_ID
		ORDER BY BFM_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_FACT_BILL_SELECT] TO rl_bill_p;
GO
