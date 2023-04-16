USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_PAY_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_PAY_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SERVICE_PAY_REPORT]
	@MANAGER		INT,
	@SERVICE		INT,
	@MONTH			UNIQUEIDENTIFIER,
	@CL_COUNT		INT = NULL OUTPUT,
	@PAY_COUNT		INT = NULL OUTPUT,
	@PAY_TOTAL		INT = NULL OUTPUT,
	@PAY_PERCENT	DECIMAL(8, 2) = NULL OUTPUT,
	@BEGIN			SMALLDATETIME = NULL,
	@END			SMALLDATETIME = NULL,
	@SORT			TINYINT = NULL,
	@DAY			BIT = 0,
	@HIDE			BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Result Table
	(
		RN				SmallInt,
		ClientID		Int,
		ClientFullName	VarChar(512),
		ServiceName		VarChar(128),
		PayType			VarChar(128),
		ContractPay		VarChar(128),
		PayDate			SmallDateTime,
		PAY				VarChar(128),
		PRC				Decimal(8, 4),
		LAST_PAY		SmallDateTime,
		PAY_DATES		VarChar(128),
		PAY_DELTA		SmallInt,
		PAY_ERROR		SmallInt,
		DistrStr		VarChar(Max),
		PAY_DATE_ERROR	SmallInt,
		LAST_MON		SmallDateTime,
		LAST_ACT		SmallDateTime,
		CL_COUNT		Int,
		PAY_COUNT		Int,
		PAY_TOTAL		Int,
		PAY_PERCENT		Decimal(8, 2)
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Result
		(
			RN,
			ClientID,
			ClientFullName,
			ServiceName,
			PayType,
			ContractPay,
			PayDate,
			PAY,
			PRC,
			LAST_PAY,
			PAY_DATES,
			PAY_DELTA,
			PAY_ERROR,
			DistrStr,
			PAY_DATE_ERROR,
			LAST_MON,
			LAST_ACT,
			CL_COUNT,
			PAY_COUNT,
			PAY_TOTAL,
			PAY_PERCENT
		)
		SELECT
			RN,
			ClientID,
			ClientFullName,
			ServiceName,
			PayType,
			ContractPay,
			PayDate,
			PAY,
			PRC,
			LAST_PAY,
			PAY_DATES,
			PAY_DELTA,
			PAY_ERROR,
			DistrStr,
			PAY_DATE_ERROR,
			LAST_MON,
			LAST_ACT,
			CL_COUNT,
			PAY_COUNT,
			PAY_TOTAL,
			PAY_PERCENT
		FROM [dbo].[ServicePay@Report]
		(
			@MANAGER,
			@SERVICE,
			@MONTH,
			@BEGIN,
			@END,
			@SORT,
			@DAY,
			@HIDE
		);

		SELECT TOP (1)
			@CL_COUNT = CL_COUNT
		FROM @Result;

		SELECT TOP (1)
			@PAY_COUNT = PAY_COUNT
		FROM @Result;

		SELECT TOP (1)
			@PAY_TOTAL = PAY_TOTAL
		FROM @Result;

		SELECT TOP (1)
			@PAY_COUNT = PAY_COUNT
		FROM @Result;

		SELECT
			RN,
			ClientID,
			ClientFullName,
			ServiceName,
			PayType,
			ContractPay,
			PayDate,
			PAY,
			PRC,
			LAST_PAY,
			PAY_DATES,
			PAY_DELTA,
			PAY_ERROR,
			DistrStr,
			PAY_DATE_ERROR,
			LAST_MON,
			LAST_ACT
		FROM @Result
		ORDER BY RN;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_PAY_REPORT] TO rl_service_pay;
GO
