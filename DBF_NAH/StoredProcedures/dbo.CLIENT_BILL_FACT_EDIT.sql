USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_BILL_FACT_EDIT]
	@bfmid INT,
	@bfmnum VARCHAR(50),
	@bfmidperiod SMALLINT,
	@billdate SMALLDATETIME,
	@clshortname VARCHAR(500),
	@clcity VARCHAR(100),
	@claddress VARCHAR(250),
	@orgshortname VARCHAR(100),
	@orgindex VARCHAR(50),
	@orgaddress VARCHAR(250),
	@orgphone VARCHAR(100),
	@orgaccount VARCHAR(50),
	@orgloro VARCHAR(50),
	@orgbik VARCHAR(50),
	@orginn VARCHAR(50),
	@orgkpp VARCHAR(50),
	@orgokonh VARCHAR(50),
	@orgokpo VARCHAR(50),
	@orgbuhshort VARCHAR(150),
	@baname VARCHAR(150),
	@bacity VARCHAR(150),
	@conum VARCHAR(500),
	@codate SMALLDATETIME
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

		UPDATE dbo.BillFactMasterTable
		SET BFM_NUM = @bfmnum,
			BFM_ID_PERIOD = @bfmidperiod,
			BILL_DATE = @billdate,
			CL_SHORT_NAME = @clshortname,
			CL_CITY = @clcity,
			CL_ADDRESS = @claddress,
			ORG_SHORT_NAME = @orgshortname,
			ORG_INDEX = @orgindex,
			ORG_ADDRESS = @orgaddress,
			ORG_PHONE = @orgphone,
			ORG_ACCOUNT = @orgaccount,
			ORG_LORO = @orgloro,
			ORG_BIK = @orgbik,
			ORG_INN = @orginn,
			ORG_KPP = @orgkpp,
			ORG_OKONH = @orgokonh,
			ORG_OKPO = @orgokpo,
			ORG_BUH_SHORT = @orgbuhshort,
			BA_NAME = @baname,
			BA_CITY = @bacity,
			CO_NUM = @conum,
			CO_DATE = @codate
		WHERE BFM_ID = @bfmid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_BILL_FACT_EDIT] TO rl_bill_w;
GO
