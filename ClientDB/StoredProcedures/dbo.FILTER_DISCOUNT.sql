USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FILTER_DISCOUNT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FILTER_DISCOUNT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[FILTER_DISCOUNT]
	@discountid			Int,
	@contracttypeid		Int,
	@startdate			SmallDateTime,
	@enddate			SmallDateTime,
	@managerid			Int				= NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Setting_CONTRACT_OLD	Bit;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Setting_CONTRACT_OLD = Cast([System].[Setting@Get]('CONTRACT_OLD') AS Bit);

        IF @Setting_CONTRACT_OLD = 1
            SELECT
		        a.ClientID, ClientFullName, ContractNumber,
		        ContractBegin, ContractTypeName, DiscountValue
	        FROM
		        dbo.ClientReadList()
		        INNER JOIN dbo.ContractTable a ON ClientID = RCL_ID
		        INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID 
		        LEFT OUTER JOIN dbo.DiscountTable c ON a.DiscountID = c.DiscountID
		        LEFT OUTER JOIN dbo.ContractTypeTable d ON d.ContractTypeID = a.ContractTypeID
	        WHERE
		        (a.ContractTypeID = @contracttypeid OR @contracttypeid IS NULL)
		        AND (a.DiscountID = @discountid OR @discountid IS NULL)
		        AND (a.ContractBegin >= @startdate OR @startdate IS NULL)
		        AND (a.ContractBegin <= @enddate OR @enddate IS NULL)
	        ORDER BY DiscountOrder, ClientFullName
	    ELSE
		    SELECT
			    CL.ClientID, ClientFullName, ContractNumber = NUM_S,
			    ContractBegin = DateFrom, ContractTypeName, DiscountValue
		    FROM [dbo].[ClientList@Get?Read]()			R
		    INNER JOIN Contract.ClientContracts	CC	ON CC.Client_Id = R.WCL_ID
		    INNER JOIN Contract.Contract		C	ON C.ID = CC.Contract_Id
		    CROSS APPLY
		    (
			    SELECT TOP (1) PayType_Id, Discount_Id, Type_Id
			    FROM Contract.ClientContractsDetails D
			    WHERE D.Contract_Id = C.ID
			    ORDER BY DATE DESC
		    ) CD
		    INNER JOIN dbo.ClientTable CL ON CL.ClientID = R.WCL_ID
		    LEFT JOIN dbo.DiscountTable D ON D.DiscountID = CD.Discount_Id
		    LEFT JOIN dbo.ContractTypeTable T ON T.ContractTypeID = CD.Type_Id
		    WHERE
				    (CD.Type_Id = @contracttypeid	OR @contracttypeid IS NULL)
			    AND (CD.Discount_ID = @discountid	OR @discountid IS NULL)
			    AND (C.DateFrom >= @startdate		OR @startdate IS NULL)
			    AND (C.DateFrom <= @enddate			OR @enddate IS NULL)
		    ORDER BY DiscountOrder, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[FILTER_DISCOUNT] TO rl_filter_discount;
GO
